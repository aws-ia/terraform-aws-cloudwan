# CloudWAN policy
locals {
  policy = <<EOF
        {
        "version": "2021.12",
        "core-network-configuration": {
            "vpn-ecmp-support": false,
            "asn-ranges": ["65000-65010"],
            "edge-locations": [
            {
                "location": "eu-west-1"
            },
            {
                "location": "us-east-1"
            }
            ]
        },
        "segments": [
            {
            "name": "nonprod",
            "require-attachment-acceptance": true
            },
            {
            "name": "prod",
            "edge-locations": ["eu-west-1", "us-east-1"],
            "require-attachment-acceptance": true
            },
            {
            "name": "sharedservices",
            "edge-locations": ["eu-west-1", "us-east-1"],
            "require-attachment-acceptance": false
            }
        ],
        "attachment-policies": [
            {
            "rule-number": 100,
            "conditions": [
                {
                "type": "tag-exists",
                "key": "prod"
                }
            ],
            "action": {
                "association-method": "constant",
                "segment": "prod"
            }
            },
            {
            "rule-number": 200,
            "conditions": [
                {
                "type": "tag-exists",
                "key": "nonprod"
                }
            ],
            "action": {
                "association-method": "constant",
                "segment": "nonprod"
            }
            },
            {
            "rule-number": 300,
            "conditions": [
                {
                "type": "tag-exists",
                "key": "sharedservices"
                }
            ],
            "action": {
                "association-method": "constant",
                "segment": "sharedservices"
            }
            }
        ]
        }
    EOF
}