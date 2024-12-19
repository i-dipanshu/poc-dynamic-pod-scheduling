import argparse
from kubernetes import client, config
import sys

# Load Kubernetes configuration
config.load_kube_config()

# Kubernetes API client
v1 = client.CoreV1Api()

# Configurable Variables
TENANT_TO_SIZE = {
    "standard": "medium",
    "premium": "large",
}

CATEGORIES = {
    # 2000Mi 4Gi
    "medium": {
        "cpu_request": "1500m", "memory_request": "3200Mi",  
        "cpu_limit": "1800m", "memory_limit": "3200Mi",
        "taint": "size=medium:NoSchedule"
    },
    # 4000Mi 16Gi
    "large": {
        "cpu_request": "3000m", "memory_request": "12000Mi",  
        "cpu_limit": "3500m", "memory_limit": "12000Mi",
        "taint": "size=large:NoSchedule"
    }
}


DEFAULT_NAMESPACE = "default"
DEFAULT_IMAGE = "nginx"
DEFAULT_NAME = "nginx-container"


def create_pod(tenant, namespace, name, image):
    # Determine pod size based on tenant input
    size = TENANT_TO_SIZE.get(tenant)
    if not size:
        raise ValueError(f"Invalid tenant category: {tenant}")

    category_info = CATEGORIES[size]

    # Define pod metadata and spec
    pod = client.V1Pod(
        metadata=client.V1ObjectMeta(
            name=name,
            labels={"size": size}, 
            namespace=namespace
        ),
        spec=client.V1PodSpec(
            containers=[
                client.V1Container(
                    name=name,
                    image=image,
                    resources=client.V1ResourceRequirements(
                        requests={
                            "cpu": category_info["cpu_request"], 
                            "memory": category_info["memory_request"]
                        },
                        limits={
                            "cpu": category_info["cpu_limit"], 
                            "memory": category_info["memory_limit"]
                        }
                    )
                )
            ],
            tolerations=[
                client.V1Toleration(
                    key="size",
                    operator="Equal",
                    value=size,
                    effect="NoSchedule"
                )
            ],
            node_selector={
                "size": size
            }
        )
    )
    return pod


def deploy_pod(tenant, namespace, name, image):
    pod = create_pod(tenant, namespace, name, image)
    try:
        v1.create_namespaced_pod(namespace=namespace, body=pod)
        print(f"Pod {pod.metadata.name} created successfully in namespace '{namespace}'!")
    except client.exceptions.ApiException as e:
        print(f"Error creating pod: {e}")


if __name__ == "__main__":
    # Command-line argument parsing
    parser = argparse.ArgumentParser(
        description="Create a Kubernetes pod based on tenant type."
                    "Valid tenant types are standard and premium."
                    "This script automatically applies taints and resource limits based on the tenant type."
    )
    parser.add_argument("--tenant", "-t", required=True, help="Tenant type: standard, or premium.")
    parser.add_argument("--namespace", "-n", default=DEFAULT_NAMESPACE, help="Kubernetes namespace (default: 'default').")
    parser.add_argument("--name", required=True, help="Name of the pod.")
    parser.add_argument("--image", default=DEFAULT_IMAGE, help="Container image (default: 'nginx').")

    args = parser.parse_args()

    # Validate tenant type
    valid_tenants = ['standard', 'premium']
    if args.tenant not in valid_tenants:
        print(f"Invalid tenant type '{args.tenant}'. Valid tenant types are: {', '.join(valid_tenants)}")
        sys.exit(1)

    try:
        deploy_pod(args.tenant, args.namespace, args.name, args.image)
    except Exception as e:
        print(f"Failed to deploy pod: {e}")