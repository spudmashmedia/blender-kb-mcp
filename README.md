# blender-kb-mcp
Blender Knowledge Base Document Ingest + MCP Server

## Summary
An MCP Server that provides Retrieval-Augmented Generation (RAG) capabilities to surface the latest Blender Python API documentation (currently v5.1.1). It is designed specifically for local usage with:
- **Inference Engines** (LM Studio, Ollama UI etc...)
- **LLM Harnesses** (OpenCode, ClaudeCode etc...)

Docker Services Include:
- **MCP Server**: built with FastMCP library.
- **Vector Database Server**: ChromaDB instance with Blender Python API Knowledge Base
- **Ingest Pipeline**: Python data ingest reading HTML + Markdown documentation and writing to ChromaDB
- **LLM Inference Engine Server**: Ollama instance using Qwen3-embedding:0.6b embedding model


# Getting Started

# Documentation

## Quick Start

### Virtual environment
```sh
  python3 -m venv bdb_env
```

### Install Dependencies

### LLM
Have Ollama installed (https://ollama.com/)
This will be used for ingestion pipeline. (See Ingestion Pipeline)

Pull Qwen3-embedding model:
```sh
ollama pull qwen3-embedding:0.6b
```

### Python
#### main
```sh
  pip install .
```

#### dev
```sh
  pip install -e ".[dev]"
```

### Run Tests
```sh
  pytest tests/ -v
```

## Ingestion Pipeline

### Pipeline Initialisation
Setup

Run:
```sh
sh ./scripts/init_ingest.sh
```

This will generate the following folder structure for processing documents:
```sh
data
├── archive
│   └── raw
├── raw
└── vectors
```


### Raw Document Loading

Place your documents in the ```/data/raw```, in this example we have a folder called docs/blender_python_reference_5_1. You can add as many document folders in here as you please.

```sh
data
├── archive
│   └── raw
├─ raw
│   ├── docs
│   │   └── blender_python_reference_5_1
│   ├── samples
│   │   └── blender_code_samples_5_1
│   └── templates
│       └── blender_templates_5_1
└── vectors

```

### Build & Run:

To build the Ingest Pipeline, run:
```sh
docker compose --profile manual build ingest
```

To start processing from the terminal run:
```sh
docker compose --profile manual up ingest
```

or if you want to run it in daemon mode and just run in the container:
```sh
docker compose --profile manual up ingest -d
```

### Document Processing Completion

On completion,
- documents are archived in data/archive/raw in the same folder structure.
- a new ChromaDB vector database file is created under data/vectors/
- a ingestion_state.json file is also created to assist with deduplicating documents that have already been processed.

```sh
data
├── archive
│   └── raw
│       ├── docs
│       │   └── blender_python_reference_5_1
│       ├── samples
│       │   └── blender_code_samples_5_1
│       └── templates
│           └── blender_templates_5_1
├── raw
└── vectors
    └── blender_api_index
        ├── 3804e5cc-113e-407d-863d-4b891b981655
        │   ├── data_level0.bin
        │   ├── header.bin
        │   ├── index_metadata.pickle
        │   ├── length.bin
        │   └── link_lists.bin
        ├── chroma.sqlite3
        └── ingestion_state.json
```


# Usage
NOTE: Have Ollama running with correct embedding model
## Ingest

### Push Data into Chroma DB
```sh
  python -m src.ingest.ingest_docs
```

### Verify Data
```sh
  python -m src.ingest.ingest_docs -v
```

## Query
```sh
  python -m src.ingest.query
```

