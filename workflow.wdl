version 1.0

workflow tabix_VCFs {

    meta {
    author: "Phuwanat Sakornsakolpat"
        email: "phuwanat.sak@mahidol.edu"
        description: "tabix VCF"
    }

     input {
        File vcf_file
    }

    call run_tabixing { 
            input: vcf = vcf_file
    }

    output {
        File tabixed_tbi = run_tabixing.out_file_tbi
    }

}

task run_tabixing {
    input {
        File vcf
        Int memSizeGB = 2
        Int threadCount = 1
        Int diskSizeGB = 2*round(size(vcf, "GB")) + 20
        String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
    mv ~{vcf} /cromwell_root/
    tabix -p vcf /cromwell_root/~{out_name}.vcf.gz
    >>>

    output {
        File out_file_tbi = select_first(glob("*.tbi"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 1
    }

}
