process PREPROCESS {

    tag "${sample_id}"
    label 'cpu'

    cpus params.preprocess_cpus
    container params.container_trq

    input:
    tuple val(sample_id), path(raw_dir), path(work_dir), path(metadata)

    output:
    tuple val(sample_id), path(work_dir), path(metadata)

    script:
    def output_flag = params.output_bquals ? '--output-base-qual' : ''

    """
    mkdir -p ${work_dir}

    tranquillyzer preprocess \\
        ${raw_dir} \\
        ${work_dir} \\
        ${output_flag} \\
        --threads ${task.cpus} \\
      > ${work_dir}/preprocess.log 2>&1
    """
}