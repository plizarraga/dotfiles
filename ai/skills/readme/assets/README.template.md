<!-- Catalog sections in their fixed order. Delete the ones step 2 did not choose; replace placeholder steps that do not fit this project. -->

![<project name> logo](<logo path>)

# <Project name>

<badges, one line>

<One or two sentences: what it does, for whom, and the problem it solves.>

[Features](#features) · [Quick Start](#quick-start) · [Usage](#usage) · [Configuration](#configuration)

![<what the screenshot shows>](<docs/images/screenshot.png>)

## Features

- **<Capability>**: <its benefit>.
- **<Capability>**: <its benefit>.
- **<Capability>**: <its benefit>.

## Tech stack

| Role | Tool |
| --- | --- |
| <Runtime> | <tool and version> |

## Quick Start

### Prerequisites

- <Runtime> <version> and <package manager> <version>
- <Account or API key, and where to get it>

### Installation

1. Clone the repository:

   ```bash
   git clone <repo url> <required location, if the code assumes one>
   cd <repo directory>
   ```

2. Install dependencies:

   ```bash
   <install command>
   ```

3. Configure the environment:

   ```bash
   cp <settings example file> <settings file>
   ```

   Fill in `<VARIABLE>` and `<VARIABLE>`. See [Configuration](#configuration).

4. <Setup the code assumes: migrations, a first user>:

   ```bash
   <setup command>
   ```

5. Start the project:

   ```bash
   <dev command>
   ```

   Open <URL> or expect <output>.

## Usage

```<language>
<smallest real example of the main job>
```

<What it produces.>

## <Project-specific section>

<Answers a question this repo's reader has.>

## Repository structure

```text
<repo>/
├── <dir>/        # <what lives here>
└── <dir>/        # <what lives here>
```

## Architecture

<One paragraph per component: what it owns and how it talks to the others.>

| Store | Purpose |
| --- | --- |
| <database, bucket, or queue> | <what it holds; link to its schema> |

## API

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/<path>` | <what it returns> |

Request:

```bash
<curl example>
```

Response:

```json
<response body>
```

## Configuration

| Variable | Required | Description |
| --- | --- | --- |
| `<NAME>` | Yes | <what it controls> |

## Testing

```bash
<test command>
```

<What each suite needs to run.>

## CI

<What runs and when.> See [`<workflow file>`](.github/workflows/<file>).

## Deployment

| Component | Platform | Notes |
| --- | --- | --- |
| <component> | <platform> | <secrets to set, deploy command> |

## Troubleshooting

- **<Symptom or exact error message>**
  <Fix.>

## Documentation

- [`<doc path>`](<doc path>): <when to read it>.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md). Releases follow <versioning scheme>; see [`CHANGELOG.md`](CHANGELOG.md). Report vulnerabilities as described in [`SECURITY.md`](SECURITY.md).

## License

<License name>. See [`LICENSE`](LICENSE).
