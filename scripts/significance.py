import json
import numpy as np
import os
from deepsig import multi_aso
import pandas as pd

if __name__ == "__main__":
    N = 5  # Number of random seeds
    M = 8  # Number of different models / algorithms

    model2idx = {
        "Single-BERT": 1,
        "Single-SpanBERT": 2,
        "Single-JobBERT": 3,
        "Single-JobSpanBERT": 4,
        "Multi-BERT": 5,
        "Multi-SpanBERT": 6,
        "Multi-JobBERT": 7,
        "Multi-JobSpanBERT": 8,
    }

    dev = {}
    test = {}

    for file in os.listdir("metrics/"):
        source, eval, model, split, _ = file.split(".")
        with open("metrics/" + file, "r") as f:
            results = json.load(f)
            if split == "dev":
                k = model2idx[str(eval + "-" + model)]
                dev[k] = np.array(
                    results["1. Strict, Combined Evaluation (official):"]["FB1"]
                )
            else:
                k = model2idx[str(eval + "-" + model)]
                test[k] = np.array(
                    results["1. Strict, Combined Evaluation (official):"]["FB1"]
                )

    eps_min_dev = multi_aso(
        dict(sorted(dev.items())),
        confidence_level=0.05,
        return_df=True,
        num_jobs=64,
        use_symmetry=True,
    )
    eps_min_test = multi_aso(
        dict(sorted(test.items())),
        confidence_level=0.05,
        return_df=True,
        num_jobs=64,
        use_symmetry=True,
    )

    print(f"development:\\ {pd.DataFrame.to_latex(eps_min_dev)}")
    print(f"test:\\ {pd.DataFrame.to_latex(eps_min_test)}")
