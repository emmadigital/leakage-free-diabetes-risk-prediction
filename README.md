# Leakage-Free Machine Learning Framework for Diabetes Risk Prediction

This repository provides the **MATLAB implementation, statistical evaluation scripts, and reproducible experiment pipeline** for the study:

**Leakage-Free Machine Learning Framework for Diabetes Risk Prediction**

The project presents a **robust evaluation framework for diabetes prediction models** that prevents information leakage during preprocessing and enables reliable comparison of machine learning algorithms across multiple datasets.

---

# Overview

Machine learning models are increasingly used for **clinical decision support and diabetes risk prediction**. However, many published studies report overly optimistic results due to **data leakage, insufficient validation strategies, or single train–test splits**.

This repository implements a **leakage-free evaluation pipeline** designed to ensure reliable model comparison and reproducible research.

The framework evaluates multiple models using:

* **Fold-contained preprocessing**
* **Multi-seed stratified cross-validation**
* **Calibration analysis**
* **Statistical significance testing**
* **Cross-dataset evaluation**

Two publicly available diabetes datasets are used to evaluate model generalizability.

---

# Datasets

The framework uses two benchmark datasets:

### Dataset 1 — Pima Indians Diabetes Dataset

* Source: UCI Machine Learning Repository
* Instances: **768**
* Features: **8 clinical variables**
* Target: **Diabetes diagnosis**

Dataset link:
[https://www.kaggle.com/uciml/pima-indians-diabetes-database](https://www.kaggle.com/uciml/pima-indians-diabetes-database)

---

### Dataset 2 — Early-Stage Diabetes Risk Dataset

* Source: UCI Machine Learning Repository
* Instances: **520**
* Features: **16 symptoms and risk factors**
* Target: **Diabetes risk**

Dataset link:
[https://archive.ics.uci.edu/ml/datasets/Early+stage+diabetes+risk+prediction+dataset](https://archive.ics.uci.edu/ml/datasets/Early+stage+diabetes+risk+prediction+dataset)

---

# Machine Learning Models

The framework evaluates six predictive models:

### Baseline Models

* Logistic Regression
* Random Forest

### Neural Network Models

* Feedforward Neural Network (FFNN)
* Backpropagation Neural Network (BPNN)
* Generalized Regression Neural Network (GRNN)
* Artificial Bee Colony optimized FFNN (ABC-FFNN)

---

# Evaluation Framework

The proposed evaluation protocol includes:

### Leakage-Free Preprocessing

All preprocessing operations are performed **only on training folds** within cross-validation.

Steps include:

* Median imputation
* Min–max normalization

Test folds never influence preprocessing parameters.

---

### Multi-Seed Stratified Cross-Validation

To ensure robust performance estimates:

* **10-fold stratified cross-validation**
* Multiple independent random seeds

| Model Type                    | Seeds    | Total Evaluations |
| ----------------------------- | -------- | ----------------- |
| Baseline models + FFNN + GRNN | 20 seeds | 200 evaluations   |
| BPNN + ABC-FFNN               | 5 seeds  | 50 evaluations    |

---

# Performance Metrics

Model performance is evaluated using both **discrimination and calibration metrics**.

### Discrimination Metrics

* Accuracy
* Sensitivity
* Specificity
* Precision
* F1-score
* ROC-AUC

### Calibration Metrics

* Brier Score
* Calibration slope
* Calibration intercept

---

# Statistical Comparison

To determine whether performance differences between models are statistically significant:

* **DeLong Test** for ROC-AUC comparison
* **McNemar Test** for classification outcomes

Statistical comparisons are computed across pooled cross-validation predictions.

---

# Repository Structure

```
Leakage-Free-Diabetes-Risk-Prediction
│
├── data
│   ├── dataset_info.md
│
├── scripts
│   ├── RUN_0_prepare_data_from_csv.m
│   ├── PREPARE_DiabetesRisk_DATASET.m
│
│   ├── RUN_LOGREG_SEEDS_CV.m
│   ├── RUN_RF_SEEDS_CV.m
│   ├── RUN_FFNN_SEEDS_CV.m
│   ├── RUN_BPNN_SEEDS_CV.m
│   ├── RUN_GRNN_SEEDS_CV.m
│   ├── RUN_ABC_FFNN_SEEDS_CV.m
│
│   ├── RUN_LOGREG_SEEDS_CV_1.m
│   ├── RUN_RF_SEEDS_CV_1.m
│   ├── RUN_FFNN_SEEDS_CV_1.m
│   ├── RUN_BPNN_SEEDS_CV_1.m
│   ├── RUN_GRNN_SEEDS_CV_1.m
│   ├── RUN_ABC_FFNN_SEEDS_CV_1.m
│
│   ├── GENERATE_STAT_TABLES_D1_D2.m
│   ├── SUMMARIZE_AND_PLOT_DIAGNOSTIC_TRADEOFF.m
│
│   ├── FIG_ROC_ALL_MODELS_BOTH_DATASETS.m
│   ├── FIG_CALIBRATION_CURVES_BOTH_DATASETS.m
│   ├── FIG_DIAGNOSTIC_TRADEOFF_BOTH_DATASETS.m
│   ├── FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.m
│   ├── Model_Ranking_Radar_Top4.m
│
├── helpers
│   ├── stratifiedGroupKFold.m
│   ├── fitMinMaxScaler.m
│   ├── applyMinMaxScaler.m
│   ├── metricsFromConfMat.m
│   ├── bootstrapAUC.m
│   ├── calibrationSlopeIntercept.m
│   ├── delong_roc_test.m
│   ├── mcnemar_test_from_predictions.m
│   ├── abc_optimize_initwb.m
│
├── results
│   ├── results_logreg_seeds.mat
│   ├── results_rf_seeds.mat
│   ├── results_grnn_seeds.mat
│   ├── results_abc_seeds.mat
│
├── figures
│   ├── ROC_curves.png
│   ├── calibration_curves.png
│   ├── diagnostic_tradeoff.png
│   ├── decision_curve.png
│   ├── radar_chart_models.png
│
├── tables
│   ├── Table4_statistical_comparison_dataset1.csv
│   ├── Table5_statistical_comparison_dataset2.csv
│
└── README.md
```

---

# Reproducibility Workflow

### Step 1 — Prepare datasets

Run:

```matlab
PREPARE_DiabetesRisk_DATASET.m
RUN_0_prepare_data_from_csv.m
```

---

### Step 2 — Train models on Dataset 1

```
RUN_LOGREG_SEEDS_CV
RUN_RF_SEEDS_CV
RUN_FFNN_SEEDS_CV
RUN_BPNN_SEEDS_CV
RUN_GRNN_SEEDS_CV
RUN_ABC_FFNN_SEEDS_CV
```

---

### Step 3 — Train models on Dataset 2

```
RUN_LOGREG_SEEDS_CV_1
RUN_RF_SEEDS_CV_1
RUN_FFNN_SEEDS_CV_1
RUN_BPNN_SEEDS_CV_1
RUN_GRNN_SEEDS_CV_1
RUN_ABC_FFNN_SEEDS_CV_1
```

---

### Step 4 — Generate statistical comparison tables

```
GENERATE_STAT_TABLES_D1_D2
```

---

### Step 5 — Generate manuscript figures

```
FIG_ROC_ALL_MODELS_BOTH_DATASETS
FIG_CALIBRATION_CURVES_BOTH_DATASETS
FIG_DIAGNOSTIC_TRADEOFF_BOTH_DATASETS
FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS
Model_Ranking_Radar_Top4
```

---

# MATLAB Requirements

The code was developed using:

* MATLAB R2025a
* Statistics and Machine Learning Toolbox
* Deep Learning Toolbox

---

# Reproducibility Notes

Key design choices implemented in this repository:

* **Fold-contained preprocessing**
* **Multiple random seeds**
* **Stratified cross-validation**
* **Independent evaluation of each fold**
* **Statistical significance testing**

These measures ensure reliable estimation of model generalization performance.

---

# Citation

If you use this repository, please cite the associated study:

```
Leakage-Free Machine Learning Framework for Diabetes Risk Prediction
```

---

# License

This project is released under the **MIT License**.

---
