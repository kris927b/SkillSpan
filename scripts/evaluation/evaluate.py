import os
import sys
import json
from collections import defaultdict
from typing import List


def evaluate(
    gold_file: str,
    pred_files: List[str],
):

    outputs = []
    for i, pred_file in enumerate(pred_files):
        # Merge predictions and gold
        merged_file = merge_pred_gold(pred_file, gold_file, i)

        out = os.popen(
            f"perl scripts/nereval.perl < {merged_file}.{i}.merged.conll"
        ).read()
        os.system(f"rm {merged_file}.{i}.merged.conll")
        outputs.append(
            {
                out.strip().split("\n")[3]: out.strip().split("\n")[4:8],
                out.strip().split("\n")[9]: out.strip().split("\n")[10:14],
                out.strip().split("\n")[15]: out.strip().split("\n")[16:20],
                out.strip().split("\n")[21]: out.strip().split("\n")[22:26],
            }
        )

    metrics = defaultdict(lambda: defaultdict(list))

    for i, output in enumerate(outputs):
        for k, v in output.items():
            acc = float(v[0][11:-2])  # Accuracy:  99.75%;
            metrics[k]["Accuracy"].append(acc)
            prec = float(v[1][12:-2])  # Precision:  59.57%;
            metrics[k]["Precision"].append(prec)
            recall = float(v[2][9:-2])  # Recall:  62.27%;
            metrics[k]["Recall"].append(recall)
            FB1 = float(v[3][6:])  # FB1:  60.89
            metrics[k]["FB1"].append(FB1)

    model_name = pred_files[1].split("/")[1]
    method = pred_files[1].split("/")[-1].split(".")[0]
    eval_set = pred_files[1].split("/")[-1].split(".")[2]
    split = pred_files[1].split("/")[-1].split(".")[1]
    json.dump(
        metrics, open(f"metrics/{eval_set}.{method}.{model_name}.{split}.json", "w")
    )


def merge_pred_gold(pred_path: str, gold_path: str, i: int) -> str:
    name = pred_path.split(".")[0]
    out_path = f"{name}.{i}.merged.conll"
    outfile = open(out_path, "w")
    with open(pred_path) as pred_fp, open(gold_path) as gold_fp:
        for pred_line in pred_fp:
            gold_line = gold_fp.readline().strip().split("\t")
            if len(gold_line) < 3:
                outfile.write("\n")
                continue
            pred_line = pred_line.strip().split("\t")
            # print(gold_line, pred_line)
            outfile.write(
                f"1\t{gold_line[0]}\t{gold_line[1]}\t{gold_line[2]}\t{pred_line[1]}\t{pred_line[2]}\n"
            )
    return name


if __name__ == "__main__":
    gold = sys.argv[1]
    preds = sys.argv[2:]
    evaluate(gold, preds)
