import json
from deepdiff import DeepDiff

# Prompt user for file paths
previous_file = input("Enter the path to the previous configuration JSON file: ").strip()
current_file = input("Enter the path to the current configuration JSON file: ").strip()
output_file = input("Enter the path to save the comparison output (e.g., output.json): ").strip()

# Load JSON files
def load_json(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

# Load previous and current configurations
previous_config = load_json(previous_file)
current_config = load_json(current_file)

# Perform the comparison
diff = DeepDiff(previous_config, current_config, ignore_order=True, report_repetition=True)

# Save the differences to a file
with open(output_file, "w", encoding="utf-8") as f:
    # Use `to_json` to serialize the DeepDiff object
    f.write(diff.to_json(indent=4))

print(f"Comparison completed. Differences saved to: {output_file}")
