#!/usr/bin/python
# -*- coding: utf-8 -*-

from github import Github
from github.Issue import Issue
from github.Repository import Repository
import os
import time
import codecs
from word_cloud import WordCloudGenerator

user: Github
user_name: str
blog_repo: Repository
cur_time: str
blog_name: str


def login():
    global user, user_name, blog_name, blog_repo
    github_repo_env = os.environ.get('GITHUB_REPOSITORY')
    user_name = github_repo_env[0:github_repo_env.index('/')]
    blog_name = github_repo_env[github_repo_env.index('/'):]
    password = os.environ.get('GITHUB_TOKEN')
    user = Github(user_name, password)
    blog_repo = user.get_repo(github_repo_env)
    print(blog_repo)


def bundle_summary_section():
    global blog_repo
    global cur_time
    global user
    global user_name
    global blog_name

    summary_section = '''
<p align='center'>
    <img src="https://badgen.net/github/issues/{0}/{1}"/>
    <img src="https://badgen.net/badge/last-commit/{2}"/>
    <img src="https://badgen.net/github/forks/{0}/{1}"/>
    <img src="https://badgen.net/github/stars/{0}/{1}"/>
    <img src="https://badgen.net/github/watchers/{0}/{1}"/>
</p>
<p align='center'>
    <a href="https://github.com/johnnian/Blog/issues/74">如果您Fork本仓库，请先阅读：如何基于Github Issues与Github Actions写技术博客？</a><br/>
    <a href="https://letgovoc.cn">TIPS：新开设了一个博客，计划输出产品技术系列主题内容，欢迎点击访问</a>
</p>

    '''.format(user_name, blog_name, cur_time)
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
    global blog_repo
    global user
    global user_name
    global blog_name

    # word cloud
    wordcloud_image_url = WordCloudGenerator(blog_repo).generate()

    list_by_labels_section = """
<summary>
    <a href="https://%s.github.io/%s/"><img src="%s" title="词云" alt="词云"></a>
</summary>  
""" % (user_name, blog_name,wordcloud_image_url)

    all_labels = blog_repo.get_labels()
    for label in all_labels:
        temp = ''
        count = 0
        issues_in_label = blog_repo.get_issues(labels=(label,), state="open")
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

    contents = [summary_section, list_by_labels_section]
    update_readme_md_file(contents)

    print('README.md updated successfully!!!')


if __name__ == '__main__':
    execute()
