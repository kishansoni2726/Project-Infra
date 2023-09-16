## Infrastructure Components


    This Infrastructure Code will Creaet following Things:
        
        1.  VPC 
        2.  Internet Gateway
        3.  Public Subnet  (x3)
        4.  Private Subnet (x3)
        5.  NAT Gateway
        6.  Elastic IP
        7.  Launch Configuration
        8.  Auto Scaling Group
        9.  Application Load Balancer
        10. Target Group
        11. RDS Postgres Instance
        12. IAM Role AmazonEC2ContainerServiceforEC2Role
        13.  Cloudwatch Alarms
                13.1 Cloudwatch Alarm for CPUUtilization of above 60% for 5 minutes
                13.2 Cloudwatch Alarm for CPUUtilization of below 40% for 20 minutes
                13.3 Cloudwatch Alarm for CPUUtilization of above 60% for 20 minutes
        14. ECR 3 Repos
                14.1 db-migration
                14.2 frontend
                14.3 backend
        15. ECS
            15.1 db-migration task on fargate
            15.2 frontend as service
            15.3 backend as service

========================================================================

To Deploy this Infra please Follow below mentioned steps:
    
    1). Clone this Repo

    2). create two files in this directory:
        
            1). secret_username.json

                +-------------------------------------------------+
                +    {                                            +
                +       "database_username": "your_username"      +
                +    }                                            +
                +-------------------------------------------------+

            2). secret_password.json

                +-------------------------------------------------+
                +    {                                            +
                +       "database_username": "your_password"      +
                +    }                                            +
                +-------------------------------------------------+
    
    3). Make sure you have terraform installed

    4). Run below mentioned command

            terraform init
            terraform plan
            terraform apply --auto-approve

    5). To destroy infra
            
            1). Delete images from ECR
            2). terraform destroy --auto-approve 
