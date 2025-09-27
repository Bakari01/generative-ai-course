# rock_paper_scissors.jac
# Interactive Rock-Paper-Scissors in Jac
# - Uses byLLM (Gemini) for computer move via `by`-style LLM function.
# - Has safe fallback (inline Python random choice) if LLM returns unexpected text.

# Import byLLM model constructor (Jac-style import)
import from byllm { Model }

# Create a global LLM instance (Gemini); change model_name if you prefer.
glob llm = Model(model_name="gemini/gemini-2.0-flash");

# Tell the LLM what type it should return — simple string
# The `by llm()` syntax lets the LLM implement the body; the docstring guides it.
def comp_choice() -> str by llm ();


# Inline Python helper used for fallback/random choice
::py::
import random
def _py_choice(lst):
    # jac will call this if we need a deterministic fallback
    return random.choice(lst)
::py::
# The game walker
walker RockPaperScissors {
    # CORRECT usage: include type annotation for `has`
    has choices: list[str] = ["rock", "paper", "scissors"];

    can play with entry {
        print("Welcome to Rock-Paper-Scissors (type 'quit' to exit).");

        while True {
            print("Your move (rock / paper / scissors): ");
            # read from stdin (Jac runs on Python runtime so input() is available)
            user = input().strip().lower();

            if user == "quit" {
                print("Thanks for playing — goodbye!");
                return;
            }

            if user not in self.choices {
                print(f"Invalid choice '{user}'. Please type rock, paper, or scissors.");
                continue;
            }

            # Ask LLM for a move
            comp_raw = comp_choice();           # LLM output (should be one word)
            comp = comp_raw.strip().lower();

            # If LLM returns garbage, fall back to random choice via inline python helper
            if comp not in self.choices {
                print(f"LLM returned unexpected response: '{comp_raw}'. Using fallback.");
                comp = _py_choice(self.choices);
            }

            print(f"Computer chose: {comp}");

            if user == comp {
                print("Result: It's a tie!");
            } elif  (user == "rock"  and comp == "scissors")
                   or (user == "paper" and comp == "rock")
                   or (user == "scissors" and comp == "paper") {
                print("Result: You win! 🎉");
            } else {
                print("Result: Computer wins. 🤖");
            }
        }
    }
}

with entry {
    game = RockPaperScissors();
    game.play('here');
}