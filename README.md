Markdown# MetaGaze: A metasurface-accelerated neural network for gaze estimation in AR/VR

<p align="center">
  <a href="#-about"><b>About</b></a> &bull;
  <a href="#-repository-structure"><b>Structure</b></a> &bull;
  <a href="#-getting-started"><b>Getting Started</b></a> &bull;
  <a href="#-datasets"><b>Datasets</b></a> &bull;
  <a href="#-pipeline--usage"><b>Pipeline & Usage</b></a> &bull;
  <a href="#-citation"><b>Citation</b></a>
</p>

---

## 📖 About
Official implementation, datasets, and supplementary analysis files for the paper: **"MetaGaze: A metasurface-accelerated neural network for gaze estimation in AR/VR"**.

This repository provides an end-to-end framework for optoelectronic hybrid gaze estimation utilizing learned metasurfaces, dual-scale U-Net segmentation with depthwise separable convolutions, and a robust polynomial/neural gaze-mapping pipeline.

---

## 📂 Repository Structure

```text
├── dataset/                      # Curated metasurface-reconstructed pseudo-eye dataset (961 images)
├── humaneye_dataset/             # In vivo human-eye dataset (1,421 images)
├── trained_results/              # Pretrained model weights (.pth) and training outputs
├── batch_extract_roi.m           # MATLAB script: Determine and extract regions of interest (ROI)
├── extract_glint_centroid.m      # MATLAB script: Locate corneal specular reflection (glint) centroids
├── new_workflow_github.ipynb     # Jupyter Notebook: End-to-end segmentation workflow & model training
├── centroid_polynomial_github.ipynb # Jupyter Notebook: Sub-pixel centroid extraction & polynomial regression for gaze mapping
└── coord_predictor_training.ipynb   # Jupyter Notebook: Neural-network-based gaze coordinate prediction

## ⚙️ Requirements & Installation
This code has been developed and tested on Linux with NVIDIA GPUs. We recommend using a Conda virtual environment.Bash
# 1. Clone the repository
git clone [https://github.com/THUMetaOptics/MetaGaze](https://github.com/THUMetaOptics/MetaGaze)
cd MetaGaze

# 2. Install dependencies (or configure via requirements.yaml / pip)
pip install -r requirements.txt

## 📦 Datasets
To ensure complete transparency and reproducibility, our curated datasets are organized as follows:Pseudo-Eye Dataset (dataset/): Contains 961 metasurface-reconstructed images with corresponding segmentation masks.Human-Eye Dataset (humaneye_dataset/): Contains 1,421 in vivo human-eye images with corresponding segmentation masks.Both complete datasets, along with their persistent DOIs, are also hosted externally for public access.

## 🚀 Pipeline & Usage
1. Preprocessing & Alignment (MATLAB)Before running deep learning pipelines, use the provided MATLAB scripts to detect the specular reflection (glint) and extract the precise regions of interest (ROI):Run extract_glint_centroid.m to locate the corneal reflection acting as a rigid fiducial marker.Run batch_extract_roi.m to crop and prepare the input frames.
2. Semantic Segmentation & Training (Python / Jupyter)new_workflow_github.ipynb: Demonstrates the dual-scale U-Net segmentation pipeline using Depthwise Separable Convolutions. It includes training protocols (Adam optimizer, initial learning rate of $1e-3$, 0.9 per-epoch decay, warm restarts every 20 epochs, and class-balanced weighted cross-entropy).
3. Gaze Estimation & Mapping (Python / Jupyter)Once segmentation masks are generated, map them to physical gaze angles using two alternative approaches:centroid_polynomial_github.ipynb: Implements binarization, sub-pixel intensity-weighted centroid extraction, StandardScaler normalization, and 2nd-order bivariate polynomial regression.coord_predictor_training.ipynb: Implements a neural network-based predictor to directly map features to gaze coordinates.

## 📝 Citation
If you find this work useful in your research, please cite:
