# mobile_elements
Nextflow workflow for the detection of mobile elements from NGS data

## Installation

Clone the git repository:
```
git clone https://github.com/Timniem/mobile_elements/
```

Get Melt from: https://melt.igs.umaryland.edu/downloads.php and unpack the tarball in ./mobile_elements/resources/melt:
```
tar -xvzf MELTvx.x.x.tar.gz
```

Create transposon file lists from ./mobile_elements/resources/melt/MELTvx.x.x/me_refs (local paths) for the genome build you want to use and add them to ./mobile_elements/resources/melt :
```
# They should be plain txt files with the local paths per line.
# Example:
"
path/to/SVA_MELT.zip
path/to/LINE1_MELT.zip
...
"

```
Add the SylabsCloud to the remotes on Apptainer:
```
apptainer remote add --no-login SylabsCloud cloud.sylabs.io
apptainer remote use SylabsCloud
```

If not already configured:
```
export APPTAINER_CACHEDIR=/path/to/your/tmp
```
Get the Singularity images and add them to ./mobile_elements/containers/ :
- SCRAMble: library://timniem/misc/scramble
- Melt: library://timniem/misc/melt

```
apptainer pull --dir 'path/to/cache/dir' container_name.sif library://timniem/container_image_path
```
## Usage

- Create a tab separated sample sheet consisting of the following sections:

| sampleID | bamFile |
| ----------- | ----------- |
| example_1 | example_1.bam |
| example_2 | example_2.bam | 

- ajust the nextflow.config to your needs (TIP: Or create a bash script for every new run, adjusting only the necessary parameters)

```
# In the mobile_elements folder:
nextflow run main.nf
```
Adjustable parameters
---
| Parameter | Description | default | required |
| ----------- | ----------- | ----------- | ----------- | 
| samplesheet | Tab-separated file with samplename and BAM path | None | Yes |
| reference_genome | Reference genome used for the alignment of the BAM | None | Yes |
| genomeBuild | Genome build version used: hg19 or hg38) | 'hg38' | Yes |
| output | Output folder in which the .VCF with MEI calls will be stored | None | Yes |


