#!/usr/bin/python
# -*- coding: utf-8 -*-

from github import Github
from github.Issue import Issue
from github.Repository import Repository
import os
import time
import urllib.parse
import codecs
from word_cloud import WordCloudGenerator

user : Github
username : str
ghiblog : Repository
cur_time : str
blogname : str

def login():
    global user, username, blogname, ghiblog
    github_repo_env = os.environ.get('GITHUB_REPOSITORY')
    username = github_repo_env[0:github_repo_env.index('/')]
    blogname = github_repo_env[1:github_repo_env.index('/')]
    password = os.environ.get('GITHUB_TOKEN')
    user = Github(username, password)
    ghiblog = user.get_repo(os.environ.get('GITHUB_REPOSITORY'))
    print(ghiblog)


def bundle_summary_section():
    global ghiblog
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
    <a href="https://github.com/jwenjian/visitor-count-badge">
        <img src="https://visitor-badge.glitch.me/badge?page_id={0}.{1}"/>
    </a>
</p>
    '''.format(username, blogname, cur_time)
    return summary_section


def format_issue(issue: Issue):
    return '- [%s](%s)  %s  \t \n' % (
        issue.title, issue.html_url, '[%s 条评论]' % issue.comments)


def update_readme_md_file(contents):
    with codecs.open('README.md', 'w', encoding='utf-8') as f:
        f.writelines(contents)
        f.flush()
        f.close()

def format_issue_with_labels(issue: Issue):
    global user, username, blogname

    labels = issue.get_labels()
    labels_str = ''

    for label in labels:
        labels_str += '[%s](https://github.com/%s/%s/labels/%s), ' % (
            label.name, username, blogname, urllib.parse.quote(label.name))
    if '---' in issue.body:
        body_summary = issue.body[:issue.body.index('---')]
    else:
        body_summary = issue.body[:150]
        # 如果前150个字符中有代码块，则在 150 个字符中重新截取代码块之前的部分作为 summary
        if '```' in body_summary:
            body_summary = body_summary[:body_summary.index('```')]

    return '''
        #### [{0}]({1}) {2} \t {3}
        
        :label: : {4}
        
        {5}
        
        [更多>>>]({1})
        
        ---
        
        '''.format(issue.title, issue.html_url, '[%s 条评论]' % issue.comments, issue.created_at, labels_str[:-2],
                   body_summary)


def bundle_list_by_labels_section():
    global ghiblog
    global user

    # word cloud
    wordcloud_image_url = WordCloudGenerator(ghiblog).generate()

    list_by_labels_section = """
<summary>
    <img src="%s" title="词云" alt="词云">
</summary>  
""" % (wordcloud_image_url)

    all_labels = ghiblog.get_labels()
    for label in all_labels:
        temp = ''
        count = 0
        issues_in_label = ghiblog.get_issues(labels=(label,),state="open")
        for issue in issues_in_label:
            temp += format_issue(issue)
            count += 1
        if count > 0:
            list_by_labels_section += '''
<details>
<summary>%s\t[%s篇文章]</summary>

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
