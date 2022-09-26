# Как запускать
Перед сборкой и запуском нужно подготовить файлы .env в директориях backend и frontend, скопировав переменные из файлов .env.example. Значения переменных могут отличаться для запуска в разных средах. 
```
docker-compose up --build
```
Первый запуск может потребовать перезапуск из-за создания БД.

# Как работает
Запускаются 3 компонента (фронт, бек, база данных). Бекенд связывается с базой через link в докере.

Фронтенд запускается на 8000 порту, бекенд - на 9000. 

```
iva@c9v:~/Documents/13Docker/backend $ docker build -t egerpro/13backend:0.0.1 .
Sending build context to Docker daemon  20.48kB
Step 1/8 : FROM python:3.9-buster
3.9-buster: Pulling from library/python
86467c57892b: Already exists 
2b34aaa3cba7: Already exists 
5a443ab54eaa: Already exists 
e6cacf42b567: Already exists 
2334d631be5e: Already exists 
22b7372a0798: Already exists 
921b037a298f: Already exists 
e1e3bcd78c58: Already exists 
12f6734d5c4b: Already exists 
Digest: sha256:1e823a8d7ff07c2ac03cd96bf4935af90b4ec135c497c6486497d38ae09a7da2
Status: Downloaded newer image for python:3.9-buster
 ---> 4793bb374b9a
Step 2/8 : RUN mkdir /app && python -m pip install pipenv
 ---> Running in 6696d7480a95
Collecting pipenv
  Downloading pipenv-2022.9.24-py2.py3-none-any.whl (3.3 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.3/3.3 MB 9.7 MB/s eta 0:00:00
Requirement already satisfied: setuptools>=36.2.1 in /usr/local/lib/python3.9/site-packages (from pipenv) (58.1.0)
Collecting virtualenv-clone>=0.2.5
  Downloading virtualenv_clone-0.5.7-py3-none-any.whl (6.6 kB)
Collecting certifi
  Downloading certifi-2022.9.24-py3-none-any.whl (161 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 161.1/161.1 KB 8.6 MB/s eta 0:00:00
Collecting virtualenv
  Downloading virtualenv-20.16.5-py3-none-any.whl (8.8 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 8.8/8.8 MB 11.2 MB/s eta 0:00:00
Collecting platformdirs<3,>=2.4
  Downloading platformdirs-2.5.2-py3-none-any.whl (14 kB)
Collecting filelock<4,>=3.4.1
  Downloading filelock-3.8.0-py3-none-any.whl (10 kB)
Collecting distlib<1,>=0.3.5
  Downloading distlib-0.3.6-py2.py3-none-any.whl (468 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 468.5/468.5 KB 10.1 MB/s eta 0:00:00
Installing collected packages: distlib, virtualenv-clone, platformdirs, filelock, certifi, virtualenv, pipenv
Successfully installed certifi-2022.9.24 distlib-0.3.6 filelock-3.8.0 pipenv-2022.9.24 platformdirs-2.5.2 virtualenv-20.16.5 virtualenv-clone-0.5.7
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 22.0.4; however, version 22.2.2 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
Removing intermediate container 6696d7480a95
 ---> b9d8738ca3cb
Step 3/8 : WORKDIR /app
 ---> Running in 0ce079f150ae
Removing intermediate container 0ce079f150ae
 ---> 422bbb4863ea
Step 4/8 : ADD Pipfile /app/Pipfile
 ---> 58441d5d5727
Step 5/8 : ADD Pipfile.lock /app/Pipfile.lock
 ---> 51e6e986ba18
Step 6/8 : RUN pipenv install
 ---> Running in 9a015e16f3af
Creating a virtualenv for this project...
Pipfile: /app/Pipfile
Using /usr/local/bin/python3.9 (3.9.14) to create virtualenv...
⠧ Creating virtual environment...created virtual environment CPython3.9.14.final.0-64 in 462ms
  creator CPython3Posix(dest=/root/.local/share/virtualenvs/app-4PlAip0Q, clear=False, no_vcs_ignore=False, global=False)
  seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/root/.local/share/virtualenv)
    added seed packages: pip==22.2.2, setuptools==65.3.0, wheel==0.37.1
  activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator

✔ Successfully created virtual environment! 
Virtualenv location: /root/.local/share/virtualenvs/app-4PlAip0Q
Installing dependencies from Pipfile.lock (e9059d)...
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
Removing intermediate container 9a015e16f3af
 ---> 9e5b5c6bd9e2
Step 7/8 : ADD main.py /app/main.py
 ---> 5a583f4be899
Step 8/8 : CMD pipenv run uvicorn main:app --reload --host 0.0.0.0 --port 9000
 ---> Running in 1ed6a0118088
Removing intermediate container 1ed6a0118088
 ---> eed33ebbb745
Successfully built eed33ebbb745
Successfully tagged egerpro/13backend:0.0.1
iva@c9v:~/Documents/13Docker/backend $ 
iva@c9v:~/Documents/13Docker/frontend $ docker build -t egerpro/13frontend:0.0.1 .
Sending build context to Docker daemon  430.6kB
Step 1/14 : FROM node:lts-buster as builder
lts-buster: Pulling from library/node
86467c57892b: Already exists 
2b34aaa3cba7: Already exists 
5a443ab54eaa: Already exists 
e6cacf42b567: Already exists 
2334d631be5e: Already exists 
9707f1b650a1: Already exists 
b83e61228626: Already exists 
5288daaaedd5: Already exists 
2edfd001ac9e: Already exists 
Digest: sha256:a5d9200d3b8c17f0f3d7717034a9c215015b7aae70cb2a9d5e5dae7ff8aa6ca8
Status: Downloaded newer image for node:lts-buster
 ---> e90654c39524
Step 2/14 : RUN mkdir /app
 ---> Running in 4eb54bda0025
Removing intermediate container 4eb54bda0025
 ---> 86d21aa42777
Step 3/14 : WORKDIR /app
 ---> Running in 0597d438c624
Removing intermediate container 0597d438c624
 ---> 559a7589f141
Step 4/14 : ADD package.json /app/package.json
 ---> c65fd069e296
Step 5/14 : ADD package-lock.json /app/package-lock.json
 ---> 697c554ef751
Step 6/14 : RUN npm i
 ---> Running in eb45974c4d54
npm WARN old lockfile 
npm WARN old lockfile The package-lock.json file was created with an old version of npm,
npm WARN old lockfile so supplemental metadata must be fetched from the registry.
npm WARN old lockfile 
npm WARN old lockfile This is a one-time fix-up, please be patient...
npm WARN old lockfile 
npm WARN deprecated urix@0.1.0: Please see https://github.com/lydell/urix#deprecated
npm WARN deprecated uuid@3.4.0: Please upgrade  to version 7 or higher.  Older versions may use Math.random() in certain circumstances, which is known to be problematic.  See https://v8.dev/blog/math-random for details.
npm WARN deprecated stable@0.1.8: Modern JS already guarantees Array#sort() is a stable sort, so this library is deprecated. See the compatibility table on MDN: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort#browser_compatibility
npm WARN deprecated source-map-url@0.4.1: See https://github.com/lydell/source-map-url#deprecated
npm WARN deprecated source-map-resolve@0.5.3: See https://github.com/lydell/source-map-resolve#deprecated
npm WARN deprecated resolve-url@0.2.1: https://github.com/lydell/resolve-url#deprecated
npm WARN deprecated querystring@0.2.0: The querystring API is considered Legacy. new code should use the URLSearchParams API instead.
npm WARN deprecated svgo@1.3.2: This SVGO version is no longer supported. Upgrade to v2.x.x.
npm WARN deprecated @babel/polyfill@7.12.1: 🚨 This package has been deprecated in favor of separate inclusion of a polyfill and regenerator-runtime (when needed). See the @babel/polyfill docs (https://babeljs.io/docs/en/babel-polyfill) for more information.
npm WARN deprecated core-js@2.6.12: core-js@<3.23.3 is no longer maintained and not recommended for usage due to the number of issues. Because of the V8 engine whims, feature detection in old core-js versions could cause a slowdown up to 100x even if nothing is polyfilled. Some versions have web compatibility issues. Please, upgrade your dependencies to the actual version of core-js.
npm WARN deprecated chokidar@2.1.8: Chokidar 2 does not receive security updates since 2019. Upgrade to chokidar 3 with 15x fewer dependencies
npm WARN deprecated chokidar@2.1.8: Chokidar 2 does not receive security updates since 2019. Upgrade to chokidar 3 with 15x fewer dependencies

added 1013 packages, and audited 1014 packages in 26s

64 packages are looking for funding
  run `npm fund` for details

32 vulnerabilities (6 moderate, 23 high, 3 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
npm notice 
npm notice New minor version of npm available! 8.15.0 -> 8.19.2
npm notice Changelog: <https://github.com/npm/cli/releases/tag/v8.19.2>
npm notice Run `npm install -g npm@8.19.2` to update!
npm notice 
Removing intermediate container eb45974c4d54
 ---> dc6d776b19c2
Step 7/14 : ADD . /app
 ---> 7f01eda18a9e
Step 8/14 : RUN npm run build && rm -rf /app/node_modules
 ---> Running in 0120664aa2db

> devops-testapp@1.0.0 build
> cross-env NODE_ENV=production webpack --config webpack.config.js --mode production

ℹ Compiling Production build progress
Browserslist: caniuse-lite is outdated. Please run:
npx browserslist@latest --update-db

Why you should do it regularly:
https://github.com/browserslist/browserslist#browsers-data-updating
✔ Production build progress: Compiled successfully in 1.57s
Hash: ec3f8bf57db6746b49f5
Version: webpack 4.46.0
Time: 1573ms
Built at: 09/25/2022 7:51:19 PM
   Asset      Size  Chunks             Chunk Names
main.css  2.46 KiB       0  [emitted]  main
 main.js  3.16 KiB       0  [emitted]  main
Entrypoint main = main.css main.js
[0] ./styles/index.less 39 bytes {0} [built]
[1] ./js/index.js + 1 modules 3.78 KiB {0} [built]
    | ./js/index.js 3.73 KiB [built]
    | ./js/config.js 43 bytes [built]
    + 2 hidden modules
Child mini-css-extract-plugin node_modules/css-loader/dist/cjs.js!node_modules/postcss-loader/src/index.js??ref--6-2!node_modules/group-css-media-queries-loader/lib/index.js!node_modules/less-loader/dist/cjs.js!styles/index.less:
    Entrypoint mini-css-extract-plugin = *
    [1] ./node_modules/css-loader/dist/cjs.js!./node_modules/postcss-loader/src??ref--6-2!./node_modules/group-css-media-queries-loader/lib!./node_modules/less-loader/dist/cjs.js!./styles/index.less 1.3 KiB {0} [built]
    [2] ./node_modules/css-loader/dist/cjs.js!./styles/normalize.css 6.59 KiB {0} [built]
        + 1 hidden module
Removing intermediate container 0120664aa2db
 ---> ad81f33b3034
Step 9/14 : FROM nginx:latest
latest: Pulling from library/nginx
31b3f1ad4ce1: Already exists 
fd42b079d0f8: Already exists 
30585fbbebc6: Already exists 
18f4ffdd25f4: Already exists 
9dc932c8fba2: Already exists 
600c24b8ba39: Already exists 
Digest: sha256:0b970013351304af46f322da1263516b188318682b2ab1091862497591189ff1
Status: Downloaded newer image for nginx:latest
 ---> 2d389e545974
Step 10/14 : RUN mkdir /app
 ---> Running in b162269ca592
Removing intermediate container b162269ca592
 ---> 8213d2447f91
Step 11/14 : WORKDIR /app
 ---> Running in 100645119e4b
Removing intermediate container 100645119e4b
 ---> d794724324cf
Step 12/14 : COPY --from=builder /app/ /app
 ---> db235d6c3a68
Step 13/14 : RUN mv /app/markup/* /app && rm -rf /app/markup
 ---> Running in 3b3fe25a6dd6
Removing intermediate container 3b3fe25a6dd6
 ---> e36c7e071136
Step 14/14 : ADD demo.conf /etc/nginx/conf.d/default.conf
 ---> 6307d89c9408
Successfully built 6307d89c9408
Successfully tagged egerpro/13frontend:0.0.1

```

```bash
iva@c9v:~/Documents/13Docker/frontend $ docker push egerpro/13backend:0.0.1
The push refers to repository [docker.io/egerpro/13backend]
...
0.0.1: digest: sha256:cfad3fd72c6ce735814d68af1d31ccd685d7e329b14aba79239d507965562c67 size: 3264
iva@c9v:~/Documents/13Docker/frontend $ docker push egerpro/13frontend:0.0.1
The push refers to repository [docker.io/egerpro/13frontend]
...
0.0.1: digest: sha256:3c1cbbb8ec77a9299cb34493baf4ba952d0de6e4b100f60cd6c4371e082b204c size: 2401

```