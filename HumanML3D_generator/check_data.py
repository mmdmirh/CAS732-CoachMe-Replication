import os
import sys

REQUIRED_PATHS = [
    'amass_data',
    'joints',
    'body_models'
]

def check():
    base_dir = os.path.dirname(__file__)
    missing = []
    for p in REQUIRED_PATHS:
        if not os.path.exists(os.path.join(base_dir, p)):
            missing.append(p)
    
    if missing:
        print(f"ERROR: Missing required data folders: {', '.join(missing)}")
        print("Please download the AMASS dataset and extract it into 'HumanML3D_generator/'.")
        print("Download URL: https://amass.is.tue.mpg.de/")
        sys.exit(1)
    print("Dataset verification successful.")

if __name__ == "__main__":
    check()
