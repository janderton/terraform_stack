name 'Terraform Stack'
rs_ca_ver 20161221
short_description "![logo](https://avatars2.githubusercontent.com/u/11051457?v=4&s=64)

Terraform-defined infrastructure stack with state preservation and audited workflow for centralized policy compliance"

long_description "### Description

This CloudApp provides state preservation, an audited workflow, and centralized policy compliance for an infrastructure stack defined in Terraform

---"

import "pft/server_templates_utilities", as: "rs_st"

##################
# User inputs    #
##################

parameter "param_git_repo" do
  type "string"
  label "Git Repo"
  category "Settings"
  default "https://github.com/adamalex/terraform_sample.git"
end

parameter "param_branch_name" do
  type "string"
  label "Branch"
  category "Settings"
  default "master"
end

parameter "param_costcenter" do 
  category "Accounting"
  label "Cost Center" 
  type "string" 
  allowed_values "Development", "QA", "Production"
  default "Development"
  operations "launch"
end

################################
# Outputs returned to the user #
################################

output "out_last_ran" do
  label "Last Ran At"
  category "Terraform"
end

output "out_last_action" do
  label "Last Action"
  category "Terraform"
end

output "out_report" do
  label "Last Action Log"
  category "Terraform"
end

output "out_message" do
  label "Message"
  category "Terraform"
  default_value 'Ready to build the infrastructure for this stack. Use the action Terraform Plan to preview and validate what will be built, then Terraform Apply to build the infrastructure'
end

############################
# RESOURCE DEFINITIONS     #
############################

resource 'utility', type: 'server' do
  name 'utility'
  cloud 'EC2 us-west-2'
  datacenter 'us-west-2c'
  instance_type 'm3.medium'
  network "Default"
  subnets 'default for us-west-2c'
  security_groups 'default'
  server_template find('Terraform', revision: 0)
end

####################
# OPERATIONS       #
####################

operation 'launch' do
  description 'Launch the application'
  definition 'launch'
end

operation 'terraform_plan' do
  label 'Terraform Plan'
  description 'Show execution plan for applying the current config'
  definition 'plan'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Plan',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

operation 'terraform_apply' do
  label 'Terraform Apply'
  description 'Apply the current configuration to the infrastructure'
  definition 'apply'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Apply',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

operation 'terraform_destroy' do
  label 'Terraform Destroy'
  description 'Destroy the infrastructure provisioned by the configuration'
  definition 'destroy'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Destroy',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

##########################
# DEFINITIONS (i.e. RCL) #
##########################

define launch($param_git_repo, $param_branch_name, $param_costcenter) do
  @@deployment.multi_update_inputs(inputs: {
    GIT_REPO: 'text:' + $param_git_repo,
    BRANCH_NAME: 'text:' + $param_branch_name,
    COST_CENTER: 'text:' + $param_costcenter
  })
end

define plan(@utility) return $report, $last_ran do
  call action(@utility, "plan") retrieve $report, $last_ran
end

define apply(@utility) return $report, $last_ran do
  call action(@utility, "apply") retrieve $report, $last_ran
end

define destroy(@utility) return $report, $last_ran do
  call action(@utility, "destroy") retrieve $report, $last_ran
end

define action(@utility, $action) return $report, $last_ran do
  call rs_st.run_script_inputs(@utility, "Terraform Execute", {
    TERRAFORM_ACTION: 'text:' + $action
  })

  $report = tag_value(@utility.current_instance(), "rs:terraform_out_url")
  $last_ran = strftime(now(), "%Y-%m-%d %H:%M:%S UTC")
end