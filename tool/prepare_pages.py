"""Configure the public Flutter client or prepare a built GitHub Pages artifact."""
import argparse
import base64
import json
import os
from pathlib import Path
import shutil
from urllib.parse import urlparse

parser = argparse.ArgumentParser()
parser.add_argument('--configure', action='store_true')
args = parser.parse_args()
if args.configure:
    url = os.environ.get('SUPABASE_URL', '').strip()
    key = os.environ.get('SUPABASE_ANON_KEY', '').strip()
    redirect = os.environ.get('WEB_AUTH_REDIRECT_URL', '').strip()
    parsed_redirect = urlparse(redirect)
    if (not url.startswith('https://') or not key or '\n' in key or '\n' in url
            or '\n' in redirect
            or parsed_redirect.scheme != 'https' or not parsed_redirect.netloc
            or parsed_redirect.path not in ('', '/') or parsed_redirect.query
            or parsed_redirect.fragment):
        raise SystemExit(
            'Set SUPABASE_URL, SUPABASE_ANON_KEY, and WEB_AUTH_REDIRECT_URL '
            'to valid production values.'
        )
    if key.startswith('sb_secret_'):
        raise SystemExit('Only a publishable or legacy anon key belongs in a web client.')
    if key.count('.') == 2:
        try:
            claims = json.loads(base64.urlsafe_b64decode(key.split('.')[1] + '==='))
            if claims.get('role') != 'anon':
                raise SystemExit('Refusing to bundle a privileged Supabase key.')
        except (ValueError, TypeError):
            raise SystemExit('Invalid client key.')
    Path('.env').write_text(
        f'SUPABASE_URL={url}\n'
        f'SUPABASE_ANON_KEY={key}\n'
        f'WEB_AUTH_REDIRECT_URL={redirect}\n'
    )
else:
    web = Path('build/web')
    # GitHub Pages serves this document for /kondwani001 and other Flutter routes.
    # The app reads the original URL and uses its client-side route.
    shutil.copyfile(web / 'index.html', web / '404.html')
    (web / '.nojekyll').touch()
    print('Prepared GitHub Pages deep-link fallback.')
