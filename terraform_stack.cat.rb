name 'Terraform Stack'
rs_ca_ver 20161221
short_description "![logo](https://avatars2.githubusercontent.com/u/11051457?v=4&s=64)

Terraform-defined infrastructure with automated operations"

long_description "### Description

This CloudApp creates and automates the operation of resources defined in Terraform

---"

import "pft/server_templates_utilities", as: "rs_st"

##################
# User inputs    #
##################

parameter "param_git_repo" do
  type "string"
  label "Git Repo"
  category "Settings"
end

parameter "param_branch_name" do
  type "string"
  label "Branch"
  category "Settings"
end

parameter "param_costcenter" do 
  category "Deployment Options"
  label "Cost Center" 
  type "string" 
  allowed_values "Development", "QA", "Production"
  default "Development"
  operations "launch"
end

################################
# Outputs returned to the user #
################################

output "out_plan_report" do
  label "Plan Report"
  category "Terraform"
end

output "out_apply_report" do
  label "Apply Report"
  category "Terraform"
end

output "out_last_run_time" do
  label "Last Run Time"
  category "Terraform"
end

output "out_message" do
  label "Message"
  category "Terraform"
  default_value 'Ready to build infrastructure for this stack. Use the Terraform Apply action to build the infrastructure, or Terraform Plan to preview what will be built'
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

operation 'terraform_plan' do
  label 'Terraform Plan'
  description 'Show execution plan for applying the current config'
  definition 'plan'
  output_mappings do {
    $out_plan_report => $plan_report,
    $out_apply_report => null,
    $out_last_run_time => $last_run_time,
    $out_message => null
  } end
end

operation 'terraform_apply' do
  label 'Terraform Apply'
  description 'Apply the current configuration to the infrastructure'
  definition 'apply'
  output_mappings do {
    $out_plan_report => null,
    $out_apply_report => $apply_report,
    $out_last_run_time => $last_run_time,
    $out_message => null
  } end
end

##########################
# DEFINITIONS (i.e. RCL) #
##########################

define plan(@utility, $param_git_repo, $param_branch_name) return @utility, $plan_report, $last_run_time do
  call rs_st.run_script_inputs(@utility, "Terraform Plan", {
    GIT_REPO: 'text:' + $param_git_repo,
    BRANCH_NAME: 'text:' + $param_branch_name,
    COST_CENTER: 'text:' + $param_costcenter
  })

  # $aws_acct_id = tag_value(@creator.current_instance(), "rs:aws_acct_id")
  # $rs_acct_id = tag_value(@creator.current_instance(), "rs:rs_acct_id")
  $last_run_time = strftime(now(), "%Y/%m/%d %H:%M:%S UTC")
  $plan_report = "(gist link)"
end

define apply(@utility, $param_git_repo, $param_branch_name) return @utility, $apply_report, $last_run_time do
  call rs_st.run_script_inputs(@utility, "Terraform Apply", {
    GIT_REPO: 'text:' + $param_git_repo,
    BRANCH_NAME: 'text:' + $param_branch_name,
    COST_CENTER: 'text:' + $param_costcenter
  })

  # $aws_acct_id = tag_value(@creator.current_instance(), "rs:aws_acct_id")
  # $rs_acct_id = tag_value(@creator.current_instance(), "rs:rs_acct_id")
  $last_run_time = strftime(now(), "%Y/%m/%d %H:%M:%S UTC")
  $apply_report = "(gist link)"
end
