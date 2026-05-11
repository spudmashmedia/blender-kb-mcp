from __future__ import annotations
import ollama
from typing import Optional
from chromadb import Client, Collection
from src.core.config import get_db_options, DbOption, QueryOption, get_llm_options, LlmOption, get_server_options, ServerOption
from src.core.db import db_init
from mcp.server.fastmcp import FastMCP

# Initialize MCP
mcp = FastMCP("Blender-5.1-API")

# Globals
db_config: Optional[DbOption] = None
llm_config: Optional[LlmOption] = None
server_config: Optional[ServerOption] = None
db_ctx = None
collection: Optional[Collection] = None

@mcp.tool()
def search_blender_api(query: str) -> str:
    """
    Search the Blender 5.1 Python API documentation. 
    Use this to find bpy.types, operators, and code samples.
    """
    try:
        # 2. Generate Embedding for the query using Ollama
        # This MUST match the model used during ingestion
        response = ollama.embed(model=llm_config.MODEL_NAME, input=[query])
        query_embedding = response["embeddings"][0]

        # 3. Query ChromaDB
        results = collection.query(
            query_embeddings=[query_embedding],
            n_results=5
        )

        if not results['documents'][0]:
            return "No matching documentation found."

        # 4. Format for the Agent
        output = [f"### Results for: {query}\n"]
        for doc, meta in zip(results['documents'][0], results['metadatas'][0]):
            source = meta.get('source', 'Unknown')
            output.append(f"**Source File:** {source}\n{doc}\n{'-'*20}")

        return "\n".join(output)

    except Exception as e:
        return f"Error accessing Blender Docs: {str(e)}"

def main():
    print(f"Hello")

    global db_config, llm_config, server_config, db_ctx, collection

    llm_config = get_llm_options()
    if not llm_config:
        print(f"Error Loading LllmOption Configuration")

    db_config = get_db_options()
    if not db_config:
        print(f"Error Loading DbOption Configuration") 
        return

    server_config = get_server_options()
    if not server_config:
        print(f"Error Loading ServerOption Configuration")
        return

    db_ctx, collection = db_init(db_config)
    print(f"Connected to ChromaDB collection {collection.name}")


    if db_ctx and collection:
        print(f"MCP server has started on {server_config.HOST}:{server_config.PORT} using transport[{server_config.TRANSPORT}]")   
        mcp.run(transport="streamable-http")


if __name__ == "__main__":
    main()
