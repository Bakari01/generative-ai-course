# 🌟 Interactive AI Doctor — Jac + byllm (Deep reasoning, safe defaults) 🌟
# - Jac handles interaction and light validation.
# - byllm (LLM) reasons about likely conditions, follow-ups, and safety.
# - LLM must NOT give prescriptions; always advise seeing a clinician for confirmation.

import from byllm { Model }

# --- Configure the model (change model_name if you prefer another provider) ---
glob llm = Model(model_name = "gemini/gemini-2.0-flash");

# --- Domain object: interactive doctor ---
obj AIDoctor {

    # Validate and start a consultation
    def consult(patient_name: str, age: int, symptoms: str, context: str = "") -> str {
        if age <= 0 {
            return "⚠️ Invalid age! Please enter a valid positive number.";
        }
        if symptoms == "" {
            return "⚠️ Please describe the symptoms so I can help.";
        }
        return get_diagnosis(patient_name, age, symptoms, context);
    }

    # Ask the LLM to produce 1–3 concise follow-up questions
    def follow_up(symptoms: str, previous_response: str) -> str {
        return get_follow_up(symptoms, previous_response);
    }
}

# --- LLM: primary diagnosis / reasoning (system parameters set in block) ---
def get_diagnosis(patient_name: str, age: int, symptoms: str, context: str) -> str by llm (
    system_prompt = get_diagnosis,
    max_tokens = 550,
    temperature = 0.6,
    top_p = 0.9,
    frequency_penalty = 0.0,
    presence_penalty = 0.0
);

sem get_diagnosis = """
You are a warm, deeply-reasoning, professional AI Doctor 🩺.

Context variables:
- Patient name: {patient_name}
- Age: {age}
- Context: {context}
- Symptoms: {symptoms}

Task:
1. Rapidly reason about the most plausible conditions (brief list).
2. For each plausible condition, give 1–2 short supporting signs from the symptoms.
3. Provide clear next steps (e.g., home care, tests to request, when to see clinic).
4. If any red-flag / emergency signs are implied (chest pain, severe breathlessness, altered consciousness, heavy bleeding), put a prominent alert line starting with "⚠️ EMERGENCY:" and instruct immediate urgent care.
5. End with a short empathetic reminder: "I am not a doctor — see a clinician for confirmation."

Tone & format:
- Friendly, concise, and structured.
- Use emojis sparingly to comfort (e.g., 🩺, ⚠️, 👍).
- Keep output under ~150 words.
- Do NOT prescribe medications or dosages.
""";

# --- LLM: follow-up question generator ---
def get_follow_up(symptoms: str, previous_response: str) -> str by llm (
    system_prompt = get_follow_up,
    max_tokens = 220,
    temperature = 0.6,
    top_p = 0.9
);

sem get_follow_up = """
You are an empathetic clinician's assistant.

Inputs:
- Previous symptoms: {symptoms}
- Previous LLM response: {previous_response}

Task:
- Generate 1–3 short, specific follow-up questions that will help narrow the differential.
- Questions must be simple, answerable by the user (yes/no or short text).
- Prioritize safety-screening questions (breathing difficulty, fainting, bleeding) if relevant.
- Include 1 short line telling the user how to answer (e.g., 'Reply: "yes" or "no"').
- Use empathetic phrasing and one emoji maximum.
- Keep it short (<= 3 lines).
""";

# --- Main interactive loop ---
with entry:__main__ {

    doc = AIDoctor();

    print("✨ Interactive AI Doctor — type 'q' at any prompt to quit. ✨");

    while True {
        patient_name = input("📝 Patient name: ");
        if patient_name == "q" {
            print("Goodbye — take care! 🌟");
            break;
        }

        age_input = input("🎂 Age (years): ");
        if age_input == "q" {
            print("Goodbye — take care! 🌟");
            break;
        }
        # Simple numeric validation
        if age_input.isdigit() {
            age = int(age_input);
        } else {
            age = -1;
        }

        symptoms = input("💬 Describe symptoms (brief): ");
        if symptoms == "q" {
            print("Goodbye — take care! 🌟");
            break;
        }

        context = input("🗒️ Context (chronic conditions, meds, allergies) — optional: ");
        if context == "q" {
            print("Goodbye — take care! 🌟");
            break;
        }

        # First-pass consult
        diagnosis = doc.consult(patient_name, age, symptoms, context);
        print("\n" + diagnosis + "\n");

        # If consult returned a validation error, skip follow-ups
        if diagnosis.startswith("⚠️") {
            continue;
        }

        # Iterative follow-up loop (max 3 rounds)
        rounds = 0;
        follow_up_needed = True;
        previous_response = diagnosis;

        while follow_up_needed and rounds < 3 {
            rounds = rounds + 1;

            follow_up_qs = doc.follow_up(symptoms, previous_response);
            print("💡 Follow-up questions:\n" + follow_up_qs + "\n");

            more_info = input("📝 Answer follow-up (or type 'done' to finish): ");
            if more_info == "q" {
                print("Goodbye — take care! 🌟");
                follow_up_needed = False;
                break;
            }
            if more_info == "done" {
                follow_up_needed = False;
                break;
            }

            # Augment symptoms with the user's short answers to refine reasoning
            symptoms = symptoms + "; " + more_info;

            # Re-run consult with updated symptom set
            previous_response = doc.consult(patient_name, age, symptoms, context);
            print("\n" + previous_response + "\n");

            # If an emergency alert appears, stop and instruct urgent action
            if "⚠️ EMERGENCY" in previous_response {
                print("Please seek emergency care immediately. This assistant is not a substitute for urgent medical services.\n");
                follow_up_needed = false;
                break;
            }
        }

        # End of patient interaction
        print("----- End of session. Stay safe and seek a clinician for definitive care. -----\n");
    }
}
