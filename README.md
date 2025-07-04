# mobile_elements
Nextflow workflow for the detection of mobile elements from NGS data

Add the SylabsCloud to the remotes on Apptainer:
```
apptainer remote add --no-login SylabsCloud cloud.sylabs.io
apptainer remote use SylabsCloud
```

If not already configured:
```
export APPTAINER_CACHEDIR=/path/to/your/tmp
```
Get the Singularity images:
SCRAMble: library://timniem/misc/scramble

```
apptainer pull --dir 'path/to/cache/dir' container_name.sif library://timniem/container_image_path
```
