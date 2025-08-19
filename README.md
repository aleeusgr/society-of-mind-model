# society-of-mind-model
a model inspired by Society of Mind using is @simonw/llm 

the core function encapsulates `cat mem.md | llm -m model -s system_prompt  > mem.md`
model is selected randomly for a list of strings, the system_prompt is a string. The output is interrupted midthought using a timer
List of model names to choose from:
MODELS=("groq-llama3-70b" "groq-llama-3.3-70b" "groq-gemma2" "groq-llama3" "groq-llama3.1-8b") 

the main function is a loop that monitors the mem.md file, shell is cleared and the contents of the file are printed, the used model is printed, then the core function is run on the file and model loops until interrupted.
