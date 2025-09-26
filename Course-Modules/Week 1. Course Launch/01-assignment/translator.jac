import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash");

def translate_to(language: str, phrase: str) -> str by llm();

with entry {
    output = translate_to(language="Welsh", phrase="Hello world");
    print(output);
}