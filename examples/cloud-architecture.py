"""
AWS Cloud Architecture — Example Python Diagrams Script

Generates an SVG showing a production-grade AWS architecture:
Route53 → CloudFront → WAF → ALB → ECS services,
with RDS primary/replica, ElastiCache, SQS/DLQ, SNS, S3, CloudWatch.

Usage:
    pip3 install diagrams
    python3 examples/cloud-architecture.py

Output:
    docs/diagrams/aws-cloud-architecture.svg (SVG format)
"""

import os

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import ECS
from diagrams.aws.database import RDS, ElastiCache
from diagrams.aws.integration import SQS, SNS
from diagrams.aws.management import Cloudwatch
from diagrams.aws.network import ALB, CloudFront, Route53
from diagrams.aws.security import WAF
from diagrams.aws.storage import S3

os.makedirs("docs/diagrams", exist_ok=True)

graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
    "ranksep": "1.0",
    "nodesep": "0.8",
}

with Diagram(
    "AWS Cloud Architecture",
    filename="docs/diagrams/aws-cloud-architecture",
    outformat="svg",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
):
    dns = Route53("Route 53\n(DNS)")
    cdn = CloudFront("CloudFront\n(CDN)")
    waf = WAF("WAF\n(Firewall)")

    with Cluster("VPC"):
        alb = ALB("Application\nLoad Balancer")

        with Cluster("ECS Cluster"):
            api_svc = ECS("API\nService")
            worker_svc = ECS("Worker\nService")
            cron_svc = ECS("Cron\nService")

        with Cluster("Data Stores"):
            rds_primary = RDS("RDS Primary\n(PostgreSQL)")
            rds_replica = RDS("RDS Replica\n(Read)")
            cache = ElastiCache("ElastiCache\n(Redis)")

        with Cluster("Messaging"):
            sqs_main = SQS("SQS\n(Main Queue)")
            sqs_dlq = SQS("SQS\n(Dead Letter)")
            sns = SNS("SNS\n(Notifications)")

    s3 = S3("S3\n(Assets)")
    monitoring = Cloudwatch("CloudWatch\n(Monitoring)")

    # Traffic flow
    dns >> cdn >> waf >> alb
    alb >> api_svc

    # Service interactions
    api_svc >> rds_primary
    api_svc >> cache
    api_svc >> sqs_main
    api_svc >> s3

    # Read replica
    api_svc >> Edge(style="dashed", label="reads") >> rds_replica
    rds_primary >> Edge(style="dashed", label="replication") >> rds_replica

    # Worker processing
    sqs_main >> worker_svc
    worker_svc >> rds_primary
    worker_svc >> sns
    sqs_main >> Edge(style="dashed", label="3 retries failed") >> sqs_dlq

    # Cron jobs
    cron_svc >> rds_primary
    cron_svc >> sqs_main

    # Monitoring
    api_svc >> Edge(style="dotted") >> monitoring
    worker_svc >> Edge(style="dotted") >> monitoring
    cron_svc >> Edge(style="dotted") >> monitoring
