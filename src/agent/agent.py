
"""HRS Agent: entry point, tool registry, and controlled tool loop.

Architecture: the model proposes; Python validates and controls. The LLM
chooses tools and composes explanations, but every tool call passes through
an allowlisted registry with validated arguments, and all tools are
read-only. Generated DDL/DML is DRAFT text for human review — never
executed by the agent.

The loop uses the MLflow Deployments gateway (Model Serving foundation
models) so the same code runs in a notebook and on a serving endpoint.
Every request is traced with MLflow for the trace UI and evaluation.
"""

import json

import mlflow
from mlflow.deployments import get_deploy_client

from src.agent import config, hrs_tools, prompts


# ---------------------------------------------------------------------------
# Tool definitions exposed to the LLM
# ---------------------------------------------------------------------------

TOOL_DEFINITIONS = [
    {
        "type": "function",
        "function": {
            "name": "get_variable_longitudinal_profile",
            "description": (
                "Classify approved HRS variables as invariant attributes "
                "or wave-specific measures, grouped into naming families "
                "(e.g. R1BMI..R16BMI -> pattern R{wave}BMI). Authority "
                "for longitudinal structure claims."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "variable_names": {
                        "type": ["array", "null"],
                        "items": {"type": "string"},
                        "description": (
                            "Optional variable names to profile; "
                            "defaults to all approved variables."
                        ),
                    },
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_approved_variables",
            "description": (
                "List approved variables with labels, Codebook evidence, "
                "and bronze match status. Authority for which variables "
                "may be used."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "variable_names": {
                        "type": ["array", "null"],
                        "items": {"type": "string"},
                    },
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "search_codebook",
            "description": (
                "Keyword-search the RAND HRS Longitudinal Codebook pages "
                "and return page numbers with excerpts. Use this to "
                "discover relevant Codebook sections by topic."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "search_terms": {
                        "type": "array",
                        "items": {"type": "string"},
                    },
                    "codebook_version": {"type": ["string", "null"]},
                },
                "required": ["search_terms"],
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_codebook_pages",
            "description": (
                "Retrieve Codebook pages by page number. Use after "
                "search_codebook or when a source page is already known."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "page_numbers": {
                        "type": "array",
                        "items": {"type": "integer"},
                    },
                    "document_id": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                },
                "required": ["page_numbers"],
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_cohort_coverage",
            "description": (
                "Summarize approved-variable coverage by wave and HRS "
                "cohort, including non-null record counts. Use before "
                "interpreting trends or generating DML."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "variable_names": {
                        "type": ["array", "null"],
                        "items": {"type": "string"},
                    },
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                    "wave_number": {"type": ["integer", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "validate_source_variables",
            "description": (
                "Check whether approved variables match physical columns "
                "in the bronze source table. Distinguishes Codebook "
                "definitions from physical columns."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "variable_names": {
                        "type": ["array", "null"],
                        "items": {"type": "string"},
                    },
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "generate_warehouse_artifacts",
            "description": (
                "Generate DRAFT silver or gold DDL/DML deterministically "
                "from approved-variable metadata. Silver uses a "
                "person-wave grain; gold aggregates by wave and "
                "demographics. Output requires human review and is never "
                "executed by this agent."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "use_case_name": {"type": ["string", "null"]},
                    "target_layer": {
                        "type": "string",
                        "enum": ["silver", "gold"],
                    },
                    "catalog": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "generate_codebook_label_dimension",
            "description": (
                "Generate a DRAFT codebook label reference dimension "
                "(dim_codebook_labels) by parsing code-to-label-to-"
                "frequency mappings from Codebook 'Categorical Variable "
                "Codes' sections for the use case's categorical "
                "variables. Returns copy-paste-ready DDL/DML with a "
                "review checklist for human review; nothing is executed."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                    "catalog": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "display_draft_artifacts",
            "description": (
                "Render DRAFT silver or gold DDL/DML in a copy-paste-ready "
                "human review format with a review checklist, copy "
                "boundaries, and destination guidance. Use this whenever "
                "the user wants to review, display, or copy generated DDL "
                "or DML. A human reviews the draft and copies the SQL "
                "into the bundle's sql/ folders; the agent never writes "
                "files or executes SQL."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "use_case_name": {"type": ["string", "null"]},
                    "target_layer": {
                        "type": "string",
                        "enum": ["silver", "gold"],
                    },
                    "catalog": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "recommend_visualizations",
            "description": (
                "Recommend visualizations and a dashboard layout grounded "
                "in approved-variable roles (longitudinal measures, "
                "invariant dimensions, coverage)."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "use_case_name": {"type": ["string", "null"]},
                    "codebook_version": {"type": ["string", "null"]},
                },
                "additionalProperties": False,
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "apply_repo_edit",
            "description": (
                "Apply an exact-match text patch to a repo SQL script "
                "(sql/ddl/, sql/dml/, sql/gold_ddl/, sql/gold_dml/ only). "
                "Use after the user accepts a DDL/DML draft to stage the "
                "edit directly in the bundle. The edit is UNCOMMITTED: "
                "always display the returned diff and remind the user to "
                "review the git diff, commit, and execute. Cannot create "
                "or delete files; cannot edit outside the sql/ folders; "
                "never executes SQL."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "repo_file": {
                        "type": "string",
                        "description": (
                            "Repo-relative path, e.g. "
                            "sql/dml/load_hrs_health_data.sql"
                        ),
                    },
                    "old_text": {
                        "type": "string",
                        "description": (
                            "Exact existing text to replace — must occur "
                            "exactly once in the file"
                        ),
                    },
                    "new_text": {
                        "type": "string",
                        "description": "Replacement text",
                    },
                },
                "required": [
                    "repo_file",
                    "old_text",
                    "new_text",
                ],
                "additionalProperties": False,
            },
        },
    },
]


TOOL_HANDLERS = {
    "get_variable_longitudinal_profile": (
        hrs_tools.get_variable_longitudinal_profile
    ),
    "get_approved_variables": hrs_tools.get_approved_variables,
    "search_codebook": hrs_tools.search_codebook,
    "get_codebook_pages": hrs_tools.get_codebook_pages,
    "get_cohort_coverage": hrs_tools.get_cohort_coverage,
    "validate_source_variables": hrs_tools.validate_source_variables,
    "generate_warehouse_artifacts": hrs_tools.generate_warehouse_artifacts,
    "generate_codebook_label_dimension": (
        hrs_tools.generate_codebook_label_dimension
    ),
    "display_draft_artifacts": hrs_tools.display_draft_artifacts,
    "recommend_visualizations": hrs_tools.recommend_visualizations,
    "apply_repo_edit": hrs_tools.apply_repo_edit,
}


def get_tool_definitions():
    """Return the allowlisted tool definitions for the LLM."""

    return [dict(tool) for tool in TOOL_DEFINITIONS]


def _validate_arguments(tool_name, arguments):
    """Reject unknown tools and non-object arguments."""

    if tool_name not in TOOL_HANDLERS:
        raise ValueError(f"Tool is not allowlisted: {tool_name}")

    if not isinstance(arguments, dict):
        raise ValueError("Tool arguments must be a JSON object.")

    return arguments


def execute_tool(tool_name, arguments):
    """Execute an allowlisted tool with validated arguments."""

    arguments = _validate_arguments(tool_name, arguments)

    try:
        result = TOOL_HANDLERS[tool_name](**arguments)
        result.setdefault("ok", True)
        return result
    except Exception as exc:
        return {
            "ok": False,
            "tool_name": tool_name,
            "error": str(exc),
        }


# ---------------------------------------------------------------------------
# Agent loop
# ---------------------------------------------------------------------------


@mlflow.trace(span_type="AGENT")
def run_agent(
    user_message,
    context=None,
    max_tool_rounds=None,
):
    """Answer an HRS question using the allowlisted agent tools.

    Args:
        user_message: The user's question.
        context: Optional reference data injected into the prompt.
        max_tool_rounds: Maximum tool-calling rounds (default from config).

    Returns:
        dict: answer, model, token usage, and a tool-call audit trail.
    """

    if not isinstance(user_message, str) or not user_message.strip():
        raise ValueError("user_message must be a nonempty string.")

    max_rounds = (
        config.MAX_TOOL_ROUNDS if max_tool_rounds is None else max_tool_rounds
    )

    if (
        isinstance(max_rounds, bool)
        or not isinstance(max_rounds, int)
        or max_rounds < 0
    ):
        raise ValueError("max_tool_rounds must be a nonnegative integer.")

    client = get_deploy_client("databricks")
    messages = prompts.build_messages(
        user_message=user_message,
        context=context,
    )

    tool_audit = []
    total_usage = {
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "total_tokens": 0,
    }

    empty_response_retries = 0

    for round_number in range(max_rounds + 1):
        response = client.predict(
            endpoint=config.LLM_ENDPOINT,
            inputs={
                "messages": messages,
                "tools": get_tool_definitions(),
                "tool_choice": "auto",
                "temperature": 0,
            },
        )

        usage = response.get("usage") or {}
        for key in total_usage:
            total_usage[key] += usage.get(key, 0) or 0

        choice = (response.get("choices") or [{}])[0]
        assistant_message = choice.get("message") or {}
        finish_reason = choice.get("finish_reason")
        tool_calls = assistant_message.get("tool_calls") or []

        if not tool_calls:
            answer = assistant_message.get("content")

            if not answer or not str(answer).strip():
                # gpt-oss occasionally stops with empty content; nudge
                # up to twice before giving up.
                if empty_response_retries < 2:
                    empty_response_retries += 1
                    messages.append(
                        {
                            "role": "user",
                            "content": (
                                "Please answer the original question. If "
                                "no tool call is needed, provide the "
                                "final answer now."
                            ),
                        }
                    )
                    continue

                raise RuntimeError(
                    "The model returned neither a final answer nor a "
                    f"tool call. Finish reason: {finish_reason}"
                )

            return {
                "answer": answer,
                "model": response.get("model"),
                "usage": total_usage,
                "tool_calls": tool_audit,
                "execution_mode": config.EXECUTION_MODE,
            }

        if round_number >= max_rounds:
            raise RuntimeError(
                f"Agent reached the limit of {max_rounds} tool rounds "
                "without a final answer."
            )

        messages.append(assistant_message)

        for call in tool_calls:
            call_id = call.get("id")
            function = call.get("function") or {}
            tool_name = function.get("name")
            raw_arguments = function.get("arguments", "{}")

            if not call_id:
                raise RuntimeError(
                    "The model returned a tool call without an ID."
                )

            try:
                arguments = json.loads(raw_arguments)

                if not isinstance(arguments, dict):
                    raise ValueError(
                        "Tool arguments must be a JSON object."
                    )

                tool_result = execute_tool(tool_name, arguments)
            except Exception as exc:
                tool_result = {
                    "ok": False,
                    "tool_name": tool_name,
                    "error": str(exc),
                }

            tool_audit.append(
                {
                    "tool_name": tool_name,
                    "ok": tool_result.get("ok", False),
                }
            )

            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": call_id,
                    "content": json.dumps(
                        tool_result,
                        default=str,
                        ensure_ascii=False,
                    ),
                }
            )

    raise RuntimeError("Agent stopped without producing a final answer.")


# ---------------------------------------------------------------------------
# MLflow model wrapper for Model Serving deployment
# ---------------------------------------------------------------------------


class HRSAgent(mlflow.pyfunc.PythonModel):
    """pyfunc wrapper so the agent can be logged and deployed.

    Accepts either a plain string question or a request body shaped like
    {"messages": [{"role": "user", "content": "..."}]} and returns the
    final assistant answer with the tool audit trail.
    """

    def predict(self, context, model_input, params=None):
        user_message = self._extract_question(model_input)
        result = run_agent(user_message)

        return {
            "messages": [
                {
                    "role": "assistant",
                    "content": result["answer"],
                }
            ],
            "answer": result["answer"],
            "model": result["model"],
            "usage": result["usage"],
            "tool_calls": result["tool_calls"],
        }

    @staticmethod
    def _extract_question(model_input):
        if isinstance(model_input, str) and model_input.strip():
            return model_input

        if isinstance(model_input, dict):
            messages = model_input.get("messages")

            if isinstance(messages, list):
                for message in reversed(messages):
                    if (
                        isinstance(message, dict)
                        and message.get("role") == "user"
                        and str(message.get("content", "")).strip()
                    ):
                        return str(message["content"])

            question = model_input.get("question")

            if isinstance(question, str) and question.strip():
                return question

        raise ValueError(
            "Input must be a question string or a "
            "{messages: [...]} chat request."
        )
