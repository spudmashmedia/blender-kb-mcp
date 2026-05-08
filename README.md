# blender-kb-mcp
Blender Knowledge Base Document Ingest + MCP Server

# Get Started

## Virtual environment
```sh
  python3 -m venv bdb_env
```

## Install Dependencies

### LLM
Have Ollama installed (https://ollama.com/)

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

