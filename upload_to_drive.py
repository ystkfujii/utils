#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import httplib2
import os
import sys
import time

from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools
from apiclient.http import MediaFileUpload

import glob

import argparse

import datetime # datetimeモジュールのインポート

CLIENT_SECRET_FILE = '/home/yfujii/.client_secrets/client_secrets.json'
# アプリケーション名
APPLICATION_NAME = 'file_upload'

# Google Driveにファイルの作成と、当該アプリで作成したファイルを取得できる権限(変更不要)
# その他の権限は以下のURLを参照: https://developers.google.com/drive/v3/web/about-auth
SCOPES = 'https://www.googleapis.com/auth/drive.file'


#try:
#    import argparse
#    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
#except ImportError:
#    flags = None

    
class GoogleDriveUploader:
    def __init__(self):
        self.credentials = self.get_credentials()
        self.http = self.credentials.authorize(httplib2.Http())
        self.service = discovery.build('drive', 'v3', http=self.http)

    def get_credentials(self):
        u'''APIのQuickstartのコードのコピペ

        https://developers.google.com/drive/v3/web/quickstart/python
        初回実行時のみブラウザに認証画面が表示され、
        認証すると~/.credentials/に認証情報が保存される
        2回目以降は保存された認証情報を利用してアクセスする
        '''
        home_dir = os.path.expanduser('~')
        credential_dir = os.path.join(home_dir, '.credentials-using-drive')
        if not os.path.exists(credential_dir):
            os.makedirs(credential_dir)
        credential_path = os.path.join(credential_dir,
                                       'drive-python-quickstart.json')

        store = oauth2client.file.Storage(credential_path)
        credentials = store.get()
        if not credentials or credentials.invalid:
            flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
            flow.user_agent = APPLICATION_NAME
            if flags:
                credentials = tools.run_flow(flow, store, flags)
            else:
                # Needed only for compatibility with Python 2.6
                credentials = tools.run(flow, store)
                print('Storing credentials to ' + credential_path)
        return credentials

    def upload_file(self, file_name, time, mime_type):
        u'''ファイルをアップロードする'''
        media_body = MediaFileUpload(file_name, mimetype=mime_type, resumable=True)
        body = {
            'name': os.path.split(file_name)[-1]+time,
            'mimeType': mime_type,
            # マイドライブ直下にファイルをアップロードする場合は次の行をコメントアウト
            'parents': [self.sub_folder_id],
        }
        self.service.files().create(body=body, media_body=media_body).execute()


 
if __name__=='__main__':
    
    mime = {
        'txt' : 'text/plain',
        'jpg' : 'image/jpeg'
        }
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--extension', '-e', choices=mime.keys(), default='txt',
                        help='selecting the upload file extension')
    parser.add_argument('--filepath', '-f', type=str, default= './',
                        help='upload file path')
    parser.add_argument('--filename', type=str, required=True, help='upload file name')
    parser.add_argument('--interval', type=int, default=1800, help='interval second')
    parser.add_argument('--loop', action='store_true')
    args = parser.parse_args()
    
    mime_type = mime[args.extension]

    uploader = GoogleDriveUploader()
    uploader.sub_folder_id = "FOLDER_ID"
    
    while args.loop:
        time.sleep(args.interval)

        d = datetime.datetime.today()
        now = d.strftime("-%Y-%m-%d_%H-%M")

        try:
            uploader.upload_file(args.filepath + args.filename, now, mime_type)
        except IOError:        
            print("No files to upload.")

    else:
        
        d = datetime.datetime.today()
        now = d.strftime("-%Y-%m-%d_%H-%M")
        
        try:
            uploader.upload_file(args.filepath + args.filename, now, mime_type)
        except IOError:        
            print("No files to upload.")
        
    
    
