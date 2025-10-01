# Rock Paper Scissors in Jac with byllm integration

import from byllm {Model}
import random;

# Configure the LLM to act as commentator
glob llm = Model(model_name = "gemini/gemini-2.0-flash");

obj RockPaperScissors {
    has choices: list = ["rock", "paper", "scissors"];

    def play(user_choice: str) -> str {
        if not (user_choice in self.choices) {
            return "Invalid choice. Choose rock, paper, or scissors.";
        }

        # Computer choice is random (fair play)
        comp_choice = random.choice(self.choices);

        result = "";
        if (user_choice == comp_choice) {
            result = "It's a tie!";
        } else {
            win = (user_choice == "rock" and comp_choice == "scissors")
                or (user_choice == "paper" and comp_choice == "rock")
                or (user_choice == "scissors" and comp_choice == "paper");

            if (win) {
                result = "You win!";
            } else {
                result = "LLM wins!";
            }
        }

        commentary = gen_comment(user_choice, comp_choice, result);

        return f"You: {user_choice}, LLM: {comp_choice} → {result} | {commentary}";
    }
}

# LLM gives playful commentary
def gen_comment(user_choice: str, comp_choice: str, result: str) -> str by llm();
sem gen_comment = """
You are a playful commentator for a rock-paper-scissors round.
Given `user_choice`, `comp_choice`, and `result`, write ONE short (<=20 words) fun commentary.
Pretend YOU (the LLM) chose `comp_choice`.
""";

# Interactive entrypoint
with entry:__main__ {
    game = RockPaperScissors();

    while True {
        choice = input("Choose rock, paper, or scissors (or 'q' to quit): ");
        if (choice == "q") {
            print("Thanks for playing!");
            break;
        }
        outcome = game.play(choice);
        print(outcome);
    }
}

