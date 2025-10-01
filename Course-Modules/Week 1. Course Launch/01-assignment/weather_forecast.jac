# 🌟 Smart Weather & Lifestyle Assistant in Jac with byllm 🌟

import from byllm {Model}
import time;

# Configure the LLM (adjust model_name if needed)
glob llm = Model(model_name = "gemini/gemini-2.0-flash");

obj WeatherLLM {
    def forecast(location: str, date: str) -> str {
        return get_forecast(location, date);
    }
}

# Inject the real system date into the semantic
glob today = time.strftime("%Y-%m-%d", time.gmtime());

# LLM handles weather, activities, safety, and geo info
def get_forecast(location: str, date: str) -> str by llm(
    system_prompt = get_forecast,
    max_tokens = 500,
    temperature = 0.7,
    top_p = 0.9,
    frequency_penalty = 0.0,
    presence_penalty = 0.0,
);
sem get_forecast = """
You are a witty, warm, and intelligent meteorologist 🌍⛅ with lifestyle advice flair.

Today's real date is {today}. Use this as the only ground truth.

Rules:
- If the requested date is before today ({today}), reply exactly with:
  "⚠️ Invalid date! Please enter today or a future date."
- If the user provides shorthand or natural language dates
  (e.g. "Fri", "Oct 1", "tmrw", "next Monday"), interpret them relative to {today}
  and normalize into YYYY-MM-DD in your response. The dates must be correct. Today is {today}.
- If the location is clearly nonsense, reply exactly with:
  "❌ Invalid location! Please enter a valid city or region."
- If the location looks like a misspelling (e.g. "Niarobi"),
  politely guess the nearest valid city or region and continue the forecast.
  Example: "Did you mean Nairobi, Kenya? Here’s the forecast ⬇️"
- If the location is valid, always mention its **continent 🌍 and country 🇨🇴** in your response.
- Keep the forecast short, fun, and natural with emojis.
- Strictly give correct dates. DO NOT make up dates.
- Get weather data from https://www.accuweather.com/en/ke/nairobi/224758/weather-forecast/224758

For valid forecasts, always use this structure:

📍 *Forecast for {{location}}, {{country}} ({{continent}}) on {{date}}:*
{{short, natural forecast with emojis}}

🎯 *Recommended activities:*
- {{1–2 fun activity suggestions based on weather}}

🛡️ *Safety tips:*
- {{1–2 safety measures with emojis}}

Keep the tone lively, supportive, and under 100 words. Use emojis to make it engaging.
""";

with entry:__main__ {
    gen = WeatherLLM();

    print("✨ Smart Weather & Lifestyle Assistant (type 'q' to quit) ✨");

    while True {
        loc = input("📍 Enter location: ");
        if (loc == "q") {
            print("Goodbye! Stay safe 🌟");
            break;
        }
        date = input("📅 Enter date (e.g. 2025-09-30, 'today', 'tomorrow'): ");
        if (date == "q") {
            print(f"Goodbye! Stay safe 🌟");
            break;
        }

        forecast = gen.forecast(loc, date);

        if ("Invalid location" in forecast or "Invalid date" in forecast) {
            print(forecast + " Try again.\n");
            continue;
        }

        print(forecast + "\n");
    }
}
