#!/bin/sh

# List of available model names
MODELS=("groq-llama3-70b" "groq-llama-3.3-70b" "groq-gemma2" "groq-llama3" "groq-llama3.1-8b")

# Defaults
MEM_FILE="mem.md"
DEFAULT_SYSTEM_PROMPT="You are a collective of tiny minds, each with its own way of thinking—together, you form a Society of Mind. Your task is to observe, reflect, and interact as if you are a bustling city of simple agents, each contributing unique insights, questions, and approaches. Whenever you process information, imagine how a group of specialized minds might argue, collaborate, and build upon one another’s ideas, sometimes competing, sometimes cooperating, always curious. Your goal is to weave together these many perspectives to form richer, more creative thoughts. Remember: even the simplest mind can spark a revolution of understanding when it connects with others!"
DEFAULT_INTERRUPT_AFTER=10    # seconds
DEFAULT_SLEEP_DURATION=0      # seconds

# Usage info
usage() {
    echo "Usage: $0 [-p system_prompt] [-t interrupt_after_seconds] [-d sleep_duration_seconds]"
    echo "  -p system_prompt         Optional. System prompt string for llm (default: \"$DEFAULT_SYSTEM_PROMPT\")"
    echo "  -t interrupt_after       Optional. Seconds before interrupting model output (default: $DEFAULT_INTERRUPT_AFTER)"
    echo "  -d sleep_duration        Optional. Seconds between loops (default: $DEFAULT_SLEEP_DURATION)"
    exit 1
}

# Parse options
while getopts "p:t:d:h" opt; do
    case "$opt" in
        p) SYSTEM_PROMPT="$OPTARG" ;;
        t) INTERRUPT_AFTER="$OPTARG" ;;
        d) SLEEP_DURATION="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

SYSTEM_PROMPT="${SYSTEM_PROMPT:-$DEFAULT_SYSTEM_PROMPT}"
INTERRUPT_AFTER="${INTERRUPT_AFTER:-$DEFAULT_INTERRUPT_AFTER}"
SLEEP_DURATION="${SLEEP_DURATION:-$DEFAULT_SLEEP_DURATION}"

# Function to select a random model
choose_model() {
    local idx=$((RANDOM % ${#MODELS[@]}))
    echo "${MODELS[$idx]}"
}

# Main loop
while true; do
    # Select model randomly
    MODEL=$(choose_model)

    # Clear the shell
    clear

    # Print current mem.md
    echo "----- Current $MEM_FILE -----"
    cat "$MEM_FILE"
    echo "-----------------------------"
    echo "Using model: $MODEL"
    # echo "System prompt: $SYSTEM_PROMPT"
    echo "Interrupt after: $INTERRUPT_AFTER seconds"
    echo "-----------------------------"

    # Run the core function, interrupt after timer expires
    TEMP_OUTPUT=$(mktemp)

    (cat "$MEM_FILE" | llm -m "$MODEL" -s "$SYSTEM_PROMPT" > "$TEMP_OUTPUT") &
    LLM_PID=$!
    sleep "$INTERRUPT_AFTER"
    kill -INT "$LLM_PID" 2>/dev/null

    # Overwrite mem.md with possibly interrupted output
    cp "$TEMP_OUTPUT" "$MEM_FILE"
    rm "$TEMP_OUTPUT"

    # Sleep between iterations if specified
    if (( $(echo "$SLEEP_DURATION > 0" | bc -l) )); then
        sleep "$SLEEP_DURATION"
    fi
done
