resource "aws_db_instance" "name" {
    allocated_storage                     = 20
    engine_version                        = "8.4.8"
    engine                               = "mysql"
   
    identifier                            = "database-1"
    instance_class                        = "db.t4g.micro"
   
    
    
    
    publicly_accessible                   = false
    
    skip_final_snapshot                   = true
    
    storage_encrypted                     = true
    
    storage_type                          = "gp2"
    
   
    username                              = "admin"
    
}

#import command for rds instance
#terraform import aws_db_instance.name <db_instance_identifier>

#terraform import command for instance class
