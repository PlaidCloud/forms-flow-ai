<div align="center"><img src=".images/logo.png"/></div>
<hr/> 
 
[![FormsFlow WEB CI](https://github.com/AOT-Technologies/forms-flow-ai/actions/workflows/forms-flow-web-ci.yml/badge.svg)](https://github.com/AOT-Technologies/forms-flow-ai/actions)
[![FormsFlow API CI](https://github.com/AOT-Technologies/forms-flow-ai/actions/workflows/forms-flow-api-ci.yml/badge.svg)](https://github.com/AOT-Technologies/forms-flow-ai/actions)
[![FormsFlow BPM CI](https://github.com/AOT-Technologies/forms-flow-ai/actions/workflows/forms-flow-bpm-ci.yml/badge.svg)](https://github.com/AOT-Technologies/forms-flow-ai/actions)
[![Join the chat at https://gitter.im/forms-flow-ai/community](https://badges.gitter.im/forms-flow-ai/community.svg)](https://gitter.im/forms-flow-ai/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Join the chat at https://stackoverflow.com/questions/tagged/formsflow.ai](https://img.shields.io/badge/ask%20-on%20%20stackoverflow-F47F24)](https://stackoverflow.com/questions/tagged/formsflow.ai?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
<img src="https://img.shields.io/badge/release-v5.3.1-blue"/>
<img src="https://img.shields.io/badge/LICENSE-Apache%202-green"/>

[**formsflow.ai**](https://formsflow.ai/) is a Free, Open-Source, Low Code Development Platform for rapidly building powerful business applications. [**formsflow.ai**](https://formsflow.ai/) combines leading Open-Source applications including [form.io](https://form.io) forms, Camunda’s workflow engine, Keycloak’s security, and Redash’s data analytics into a seamless, integrated platform.


## How It Works ?

Check out the [installation documentation](https://aot-technologies.github.io/forms-flow-installation-doc/) for installation instructions and [features documentation](https://aot-technologies.github.io/forms-flow-ai-doc) to explore features and capabilities in detail.

## License

Copyright 2020 AppsOnTime-Technologies 2020

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## PlaidCloud

These are the docs for how to build various components of forms flow for use in PlaidCloud ecosystem.

Things you'll need:

- `docker` (authenticated with our Google Artifact Registry)
- `gcloud` if uploading build files from CLI
- [forms-flow-ai-micro-front-ends](https://github.com/PlaidCLoud/forms-flow-ai-micro-front-ends) cloned locally, side-by-side with this repo:
  - `projects/`
    - `forms-flow-ai/`
    - `forms-flow-ai-micro-front-ends/`

Once the above is done, follow these steps to prepare a specific formsflow version for build:

- If not done already, add upstream repo as a remote:
  - `cd forms-flow-ai-micro-front-ends && git remote add upstream git@github.com:AOT-Technologies/forms-flow-ai-micro-front-ends.git`
  - `cd forms-flow-ai && git remote add upstream git@github.com:AOT-Technologies/forms-flow-ai.git`
- Pull latest from `upstream` in both projects to fetch any new tagged versions:
  - `git pull upstream`
- If not done already, check out `plaidcloud` branch in both projects:
  - `git checkout plaidcloud`
- For both projects, rebase `plaidcloud` onto the tag you wish to build, and resolve conflicts (if any):
  - `git rebase v5.3.1`

After the above setup is done, the individial forms-flow projects should be ready for building.

### How To Build `forms-flow-web` Image

To build the image:
- Run `build-web.sh` from `forms-flow-ai` root directory, specifying the tag you've rebased onto:
  - `./build-web.sh v5.3.1`

To upload build files to CDN:
- Log into google cloud console
- Navigate to [plaidcloud-cdn](https://console.cloud.google.com/storage/browser/plaidcloud-cdn/formsflow?project=plaidcloud-io) formsflow directory
- Create a new folder named after the version tag
- Upload everything in the `output/$VERSION_TAG` dir

Alternatively, use `gcloud` CLI:
- `VERSION_TAG=v5.3.1`
- `gcloud storage cp --recursive output/$VERSION_TAG gs://plaidcloud-cdn/formsflow/$VERSION_TAG/`