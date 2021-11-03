import json
import numpy as np
import os
from deepsig import multi_aso


if __name__ == "__main__":
    N = 5  # Number of random seeds
    M = 4  # Number of different models / algorithms

    sources = ["big", "house", "tech", "Combined"]

    for source in sources:
        skill = {}
        knowledge = {}
        multi = {}
        for file in os.listdir("metrics/"):
            if file.startswith(source):
                source, eval_, model, _ = file.split(".")
                with open("metrics/" + file, "r") as f:
                    results = json.load(f)
                    if eval_ == "Skills":
                        skill[str(model)] = np.array(
                            results["3.1 Per-Level Evaluation (outer chunks):"]["FB1"]
                        )
                    if eval_ == "Knowledge":
                        knowledge[str(model)] = np.array(
                            results["3.2 Per-Level Global Evaluation (inner chunks):"][
                                "FB1"
                            ]
                        )
                    if eval_ == "Multi":
                        multi[str(model)] = np.array(
                            results["1. Strict, Combined Evaluation (official):"]["FB1"]
                        )

        # eps_min_skill = multi_aso(skill, confidence_level=0.05, return_df=True, num_jobs=4, use_symmetry=True)
        eps_min_knowledge = multi_aso(
            knowledge,
            confidence_level=0.05,
            return_df=True,
            num_jobs=4,
            use_symmetry=True,
        )
        # eps_min_multi = multi_aso(multi, confidence_level=0.05, return_df=True, num_jobs=6, use_symmetry=True)

        # print(f"{source}, skill:\\ {eps_min_skill}")
        print(f"{source}, knowledge:\\ {eps_min_knowledge}")
        # print(f"{source}, multi:\\ {eps_min_multi}")
