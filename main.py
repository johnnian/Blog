#!/usr/bin/python
# -*- coding: utf-8 -*-

from github import Github
from github.Issue import Issue
from github.Repository import Repository
import os
import time
import codecs
from word_cloud import WordCloudGenerator

user : Github
username : str
blogrepo : Repository
cur_time : str
blogname : str

def login():
    global user, username, blogname, blogrepo
    github_repo_env = os.environ.get('GITHUB_REPOSITORY')

    username = github_repo_env[0:github_repo_env.index('/')]
    blogname = github_repo_env[github_repo_env.index('/'):]
    password = os.environ.get('GITHUB_TOKEN')
    user = Github(username, password)
    blogrepo = user.get_repo(os.environ.get('GITHUB_REPOSITORY'))
    print(blogrepo)


def bundle_summary_section():
    global blogrepo
    global cur_time
    global user
    global username
    global blogname

    summary_section = '''
<p align='center'>
    <img src="https://badgen.net/github/issues/{0}/{1}"/>
    <img src="https://badgen.net/badge/last-commit/{2}"/>
    <img src="https://badgen.net/github/forks/{0}/{1}"/>
    <img src="https://badgen.net/github/stars/{0}/{1}"/>
    <img src="https://badgen.net/github/watchers/{0}/{1}"/>
</p>
    '''.format(username, blogname, cur_time)
    return summary_section


def format_issue(issue: Issue):
    return '- %s [%s](%s) \n' % (
            issue.created_at.strftime('%Y-%m-%d'),
            issue.title,
            issue.html_url)


def update_readme_md_file(contents):
    with codecs.open('README.md', 'w', encoding='utf-8') as f:
        f.writelines(contents)
        f.flush()
        f.close()

def bundle_list_by_labels_section():
    global blogrepo
    global user
    global username
    global blogname


    # word cloud
    wordcloud_image_url = WordCloudGenerator(blogrepo).generate()

    list_by_labels_section = """
<summary>
    <img src="%s" title="词云" alt="词云" href="https://%s.github.io/%s/">
</summary>  
""" % (wordcloud_image_url,username,blogname)

    all_labels = blogrepo.get_labels()
    for label in all_labels:
        temp = ''
        count = 0
        issues_in_label = blogrepo.get_issues(labels=(label,),state="open")
        for issue in issues_in_label:
            temp += format_issue(issue)
            count += 1
        if count > 0:
            list_by_labels_section += '''
<details open>
<summary>%s\t[%s篇]</summary>

%s

</details>
            ''' % (label.name, count, temp)

    return list_by_labels_section


def execute():
    global cur_time
    # common
    cur_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

    # 1. login & init rope
    login()

    # 2. summary section
    summary_section = bundle_summary_section()
    print(summary_section)

    # 3. list by labels section
    list_by_labels_section = bundle_list_by_labels_section()
    print(list_by_labels_section)

    contents = [summary_section,list_by_labels_section]
    update_readme_md_file(contents)

    print('README.md updated successfully!!!')

if __name__ == '__main__':
    execute()
