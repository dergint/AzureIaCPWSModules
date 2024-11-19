import json
from deepdiff import DeepDiff


# File paths
previous_file = "/Users/dergin1/m365dsc/SkyDlpRuleExport_2024-Nov-11.json"
current_file = "/Users/dergin1/m365dsc/SkyDlpRuleExport_2024-Nov-18.json"
output_file = "/Users/dergin1/m365dsc/DlpConfigChanges.json"

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
