#!/usr/bin/env python3

'''
Automate configuration of new Gitlab instance
create new user, group and project
https://python-gitlab.readthedocs.io/en/stable/index.html
'''

import sys
import gitlab
import argparse

# user settings
mynewuser = 'vagrant'
mynewuser_pass = 'mYp45sslol'
mynewuser_email = mynewuser + '@localhost'
mynewuser_ssh_key = '/home/vagrant/.ssh/id_rsa.pub'

# group + project name
group_name = 'coders'
project_name = 'controlrepo'
deploy_ssh_key = '/opt/boxlab/config/pekey001.ed25519.pub'

def setup_gitlab_connection(url, private_token):
    try:
        return gitlab.Gitlab(url=url, private_token=private_token)
    except gitlab.exceptions.GitlabError as e:
        print(f"[!] Error setting up GitLab connection: {e}")
        sys.exit(1)


def create_gitlab_group(gl, group_name):
    existing_groups = gl.groups.list(search=group_name)
    if existing_groups:
        group = existing_groups[0]
        print(f"[.] Group '{group_name}' already exists.")
    else:
        group = gl.groups.create({
            'name': group_name,
            'description': 'devops automation',
            'path': group_name
        })
        print(f"[*] Group '{group_name}' created.")
    return group


def create_gitlab_project(gl, group, project_name):
    group_obj = gl.groups.get(group)
    projects = group_obj.projects.list(search=project_name)
    if projects:
        project = projects[0]
        print(f"[.] Project '{project_name}' already exists.")
    else:
        project = gl.projects.create({
            'name': project_name,
            'description': 'Puppet control repo',
            'visibility': 'private',
            'namespace_id': group_obj.id
        })
        print(f"[*] Project '{project_name}' created.")
        # add read only deploy key
        key = project.keys.create({'title': 'devops_automation', 'key': open(deploy_ssh_key).read()})
    return project


def create_gitlab_user(gl, username, email, password, ssh_key_path):
    existing_users = gl.users.list(username=username)
    if existing_users:
        print(f"[.] User '{username}' already exists.")
        user = existing_users[0]
    else:
        user = gl.users.create({
            'email': email,
            'password': password,
            'username': username,
            'name': 'devops_automation'
        })
        print(f"[*] User '{username}' created.")
        # Add SSH key to the user's profile
        with open(ssh_key_path, 'r') as ssh_key_file:
            ssh_key = ssh_key_file.read()
            user.keys.create({'title': 'My SSH Key', 'key': ssh_key})
    return user


def grant_admin_permissions(gl, user, group_name, project_name):
    group = gl.groups.get(group_name)
    project = gl.projects.get(f'{group_name}/{project_name}')
    group_members = group.members.list(username=user.username)
    if not group_members:
        group.members.create({
            'user_id': user.id,
            'access_level': gitlab.MASTER_ACCESS
        })
        print(f"[*] User '{user.username}' granted admin access to group '{group_name}'.")
    project_members = project.members.list(username=user.username)
    if not project_members:
        project.members.create({
            'user_id': user.id,
            'access_level': 50
        })
        print(f"[*] User '{user.username}' granted admin access to project '{project_name}'.")


def list_all_users(gl):
    users = gl.users.list()
    print("--- List all users ---")
    for user in users:
        print(f"Username: {user.username} \tName: {user.name} \t\tID: {user.id}")

def list_all_projects(gl):
    projects = gl.projects.list(all=True)
    print("--- List all projects ---")
    for project in projects:
        print(f"Project ID: {project.id} \tName: {project.name} \tPath: {project.path}")

def list_all_groups(gl):
    groups = gl.groups.list(all=True)
    print("--- List all groups ---")
    for groups in groups:
        print(f"groups ID: {groups.id} \tName: {groups.name} \t\tPath: {groups.path}")


if __name__ == "__main__":
    # cli args
    parser = argparse.ArgumentParser(description='List all GitLab users and projects.')
    parser.add_argument('--url', required=True, help='GitLab server URL')
    parser.add_argument('--token', required=True, help='Private Access Token')
    args = parser.parse_args()

    # Set up GitLab connection
    print("[*] start gitlab config")
    gl = setup_gitlab_connection(url=args.url, private_token=args.token)

    # Create GitLab group
    group = create_gitlab_group(gl, group_name)

    # Create GitLab project under this group
    project = create_gitlab_project(gl, group_name, project_name)

    # Create non-root user
    newuser = create_gitlab_user(gl, mynewuser, mynewuser_email, mynewuser_pass, mynewuser_ssh_key)

    # give user admin to group and project
    newuser_perm = grant_admin_permissions(gl, newuser, group_name, project_name)

    # List all GitLab users
    list_all_users(gl)

    # List all GitLab projects
    list_all_projects(gl)

    # List all groups
    list_all_groups(gl)

    print("[*] gitlab config script ran")