"""
G-Eval scoring using Azure OpenAI GPT-4o.
Evaluates generated coaching instructions for consistency with ground truth.
Usage:
    python geval_azure.py \
        --predictions results/skating_evaluation/jsons/results_epoch200.json \
        --ground_truth GEval/ground_truth_test.json \
        --endpoint https://eastus.api.cognitive.microsoft.com/openai/deployments/gpt-4o/chat/completions?api-version=2025-01-01-preview \
        --api_key YOUR_KEY_HERE \
        --output GEval/skating_geval_scores.json
"""

import json
import argparse
import time
import urllib.request
import urllib.error

GEVAL_PROMPT = """You are evaluating the quality of AI-generated sports coaching instructions.

Given:
- Ground truth coaching instruction (written by a human coach)
- Generated coaching instruction (produced by an AI model)

Rate the CONSISTENCY of the generated instruction with the ground truth on a scale of 1 to 5:
1 = Completely inconsistent or irrelevant
2 = Mostly inconsistent, only minor overlap
3 = Partially consistent, captures some key points
4 = Mostly consistent, minor differences
5 = Highly consistent, captures the main coaching point accurately

Ground Truth: {ground_truth}

Generated: {generated}

Respond with ONLY a single integer from 1 to 5."""


def score_pair(endpoint, api_key, ground_truth, generated, max_retries=3):
    prompt = GEVAL_PROMPT.format(ground_truth=ground_truth, generated=generated)
    payload = json.dumps({
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 5,
        "temperature": 0.0
    }).encode("utf-8")

    headers = {
        "Content-Type": "application/json",
        "api-key": api_key
    }

    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(endpoint, data=payload, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=30) as resp:
                result = json.loads(resp.read().decode("utf-8"))
                text = result["choices"][0]["message"]["content"].strip()
                score = int(text[0])
                if 1 <= score <= 5:
                    return score
                return 3
        except (urllib.error.HTTPError, urllib.error.URLError) as e:
            print(f"  Request error (attempt {attempt+1}): {e}")
            time.sleep(2 ** attempt)
        except (ValueError, KeyError, IndexError) as e:
            print(f"  Parse error: {e}, text was: {text!r}")
            return 3
    return 3


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--predictions", required=True)
    parser.add_argument("--ground_truth", required=True)
    parser.add_argument("--endpoint", required=True)
    parser.add_argument("--api_key", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--delay", type=float, default=0.5, help="Seconds between API calls")
    args = parser.parse_args()

    with open(args.predictions) as f:
        predictions = json.load(f)
    with open(args.ground_truth) as f:
        ground_truth = json.load(f)

    # Only score keys present in both
    common_keys = [k for k in predictions if k in ground_truth]
    print(f"Scoring {len(common_keys)} samples (of {len(predictions)} predictions, {len(ground_truth)} ground truth)")

    scores = {}
    for i, key in enumerate(common_keys):
        gt = ground_truth[key]
        pred = predictions[key]
        score = score_pair(args.endpoint, args.api_key, gt, pred)
        scores[key] = score
        if (i + 1) % 10 == 0 or i == 0:
            running_avg = sum(scores.values()) / len(scores)
            print(f"  [{i+1}/{len(common_keys)}] key={key[:20]}... score={score}  running_avg={running_avg:.3f}")
        time.sleep(args.delay)

    avg = sum(scores.values()) / len(scores)
    result = {
        "scores": scores,
        "average": round(avg, 4),
        "n": len(scores)
    }

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)

    print(f"\nFinal G-Eval score: {avg:.4f} over {len(scores)} samples")
    print(f"Results saved to {args.output}")


if __name__ == "__main__":
    main()
