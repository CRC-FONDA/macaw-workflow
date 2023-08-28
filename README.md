
This repository contains the Nextflow code for the magnetometer calibration workflow Macaw. 
The binary folder is empty due to ip restrictions.

### BibTeX
```bibtex
@INPROCEEDINGS{baderStypMacaw22,
  author={Bader, Jonathan and Styp-Rekowski, Kevin and Doehler, Leon and Becker, Soeren and Kao, Odej},
  booktitle={2022 IEEE International Conference on Data Mining Workshops (ICDMW)}, 
  title={Macaw: The Machine Learning Magnetometer Calibration Workflow}, 
  year={2022},
  volume={},
  number={},
  pages={1095-1101},
  doi={10.1109/ICDMW58026.2022.00142}}
```

### Running the Workflow on K8s

Select the `nodeSelector` task property and execute:

`nextflow kuberun https://github.com/CRC-FONDA/macaw-workflow -r main -v pvc-name:/mount/path`