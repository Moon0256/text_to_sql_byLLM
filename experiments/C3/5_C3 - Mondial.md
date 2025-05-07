# What the Code Is Doing (In Simple Terms)


<pre><code> 
# Text2SQL: Step-by-Step Explanation of the Code

# 1. Load required libraries and environment
from langchain_openai import ChatOpenAI  # OpenAI language model API (https://python.langchain.com/docs/integrations/chat/openai)
from urllib.parse import quote            # Helps safely encode passwords in URLs
from dotenv import load_dotenv            # Loads .env file with environment variables (https://pypi.org/project/python-dotenv/)
import time, os, sys, json

# Load OpenAI API key from .env file located two folders up
load_dotenv(dotenv_path=os.path.join("..","..",".env"))

# 2. Load helper functions for prompt engineering and SQL generation
from c3_clear_prompting import generate_clear_prompting         # Converts question into a DB-understandable prompt
from c3_calibration_with_hints import generate_calibration_with_hints # Adds hints to clarify the prompt
from c3_generate_sql import generate_sql                         # Sends prompt to LLM and gets back SQL query

# 3. Add custom module paths to the system
current_dir = os.path.abspath('')
functions_path = os.path.abspath(os.path.join(current_dir, '..', '..', 'functions'))
if functions_path not in sys.path:
    sys.path.append(functions_path)

# 4. Import database connection utility and define constants
from sqldatabase_langchain_utils import SQLDatabaseLangchainUtils  # Wrapper to interact with DB via LangChain
from oracle_connection import get_oracle_connection                # Optional: function to get cx_Oracle connection

SCHEMA = 'MONDIAL'
PREFIX = 'mondial'
FILE_NAME_RESULT = f"results/5_c3_queries_chatgpt_{SCHEMA}_fk.json"

# 5. Define save/load helpers for result files
def save_queries(queries):
    with open(FILE_NAME_RESULT, "w") as arquivo_json:
        json.dump({"queries":queries}, arquivo_json, indent=4) 

def read_queries():
    with open(FILE_NAME_RESULT, encoding='utf-8', errors='ignore') as json_data:
        return json.load(json_data, strict=False)["queries"]

# 6. Define DB connection configuration
db_connection = {
    "DB_USER_NAME": "MONDIAL",
    "DB_PASS": "oraclee",
    "DB_HOST": "localhost",
    "DB_PORT": 1521,
    "DB_NAME": "XE",  # Oracle SID
    "SQL_DRIVER": "oracle+oracledb",
    "SERVICE_NAME": "XE"
}

# 7. Initialize the DB utility (https://python.langchain.com/docs/modules/data_connection/sql_database/)
db = SQLDatabaseLangchainUtils(db_connection=db_connection, schema='MONDIAL')

# 8. Filter out irrelevant/log system tables
exclusao = [
    f"{SCHEMA}_tmdp", f"{SCHEMA}_tmdpmap", f"{SCHEMA}_tmds", f"{SCHEMA}_tmjmap", f"{SCHEMA}_tpv",
    f"{SCHEMA}_tmdc", f"{SCHEMA}_tmdcmap", f"{SCHEMA}_tmdej", f"{SCHEMA}_log_action", f"{SCHEMA}_log_error",
    f"{SCHEMA}_favorite_item", f"{SCHEMA}_favorite_query", f"{SCHEMA}_favorite_tag", f"{SCHEMA}_favorite_tag_item",
    f"{SCHEMA}_favorite_visualization", f"{SCHEMA}_dashboard", f"{SCHEMA}_history",
    "teste_cliente", "teste_fornecedor", "teste_funcionario"
]

# 9. Get clean list of usable tables
include_tables = [s for s in db.get_table_names() if not s.startswith(PREFIX) and s not in exclusao]
db = SQLDatabaseLangchainUtils(db_connection=db_connection, include_tables=include_tables, schema='MONDIAL')

# 10. Define main execution function
# Docs: https://python.langchain.com/docs/integrations/chat/openai/#chatopenai

def run_c3(question, db, model='gpt-3.5-turbo', add_fk=True, callback=None):
    llm = ChatOpenAI(model_name=model, temperature=0.7, n=1)  # Creates a language model with 1 output
    clear_prompting = generate_clear_prompting(question, db, llm, add_fk=add_fk, callback=callback)
    print(clear_prompting)  # Shows the final prompt being sent to OpenAI
    messages = generate_calibration_with_hints(clear_prompting)
    llm = ChatOpenAI(model_name=model, n=1)
    sql = generate_sql(messages, llm, db, question, callback=callback)
    return sql

# 11. Load pre-written questions
json_file_path = f"../../datasets/{PREFIX}/queries_{PREFIX}.json"
with open(json_file_path, encoding='utf-8', errors='ignore') as json_data:
    queries = json.load(json_data, strict=False)['queries']

# 12. Token tracking utils to see cost of each query
track_token = [] 
def tracking_token(cb=None, reset=False):
    global track_token
    track_token.append(cb)
    if reset:
        track_token = []

def convert_to_dict_tracking_token():
    token_usage = {}
    for e in track_token:
        for key in e:
            token_usage[key] = {
                'total_tokens': e[key].total_tokens,
                'total_cost': e[key].total_cost,
                'prompt_tokens': e[key].prompt_tokens,
                'completion_tokens': e[key].completion_tokens
            }
    return token_usage

# 13. Example: Run one query at a time
sql = run_c3("What are the languages spoken in Poland?", db, callback=tracking_token)
print(convert_to_dict_tracking_token())
print(sql)
</code></pre>

### Importing Tools

You're loading helpful tools from Python libraries to talk to OpenAI and Oracle, read data, and keep everything organized.

You also read a secret key from a file called .env that lets you use OpenAI. This key is like your "ticket" to use ChatGPT.


### Loading Helper Functions

You bring in helper code from other files (generate_clear_prompting, generate_sql, etc.) that make questions easier to understand and turn them into SQL code.

You set up the connection to the Oracle database where the Mondial world data lives.


### Defining What Tables to Include
You look at all the tables in the database and exclude any “junk” ones (like logs or test tables) using some filters.

### run_c3() – The Main Star ⭐
This function takes a question like “What languages are spoken in Poland?” and:
Talks to OpenAI to understand the question.
Generates an answer in the form of an SQL query.
Uses your database setup to match the question to your data.
### Tracking Cost
You count how many tokens OpenAI used to answer, so you know how much you’re spending.
### Running All the Questions
You loop through all questions in your dataset, send them one by one to OpenAI, and save the SQL responses.
### Fixing Bad Ones
You retry specific questions that didn’t work earlier.
### 🛠 Edits to Make for One-at-a-Time Querying
Right now, your script automatically loops through all the queries at the end, which can be expensive.

You can safely comment out or remove this big loop so that you can manually run one query at a time like this:

sql = run_c3("What are the languages spoken in Poland?", db, callback=tracking_token)
print(sql)
print(convert_to_dict_tracking_token())
👉 Remove or comment out this part for now:

## Loop through all queries
for instance in queries:
    ...
👉 Also comment out this "to_fix" block:

## Fixing specific failed queries
to_fix = [59,62,72,85,99]
for pos in to_fix:
    ...
✅ What You Should Do Now
✅ Keep your run_c3() function — it works perfectly for testing single questions.
🔒 Keep your .env file only in the main folder (your current setup is fine).
🛑 Avoid looping through all the queries for now — only run 1 at a time manually.
🪙 Always check the token usage to keep costs low.
💡 Suggested Extra Tweaks
(Optional) Print token usage in run_c3 directly:

Add this inside run_c3():

    with get_openai_callback() as cb:
        sql = generate_sql(messages, llm, db, question, callback=callback)
        print("Tokens used:", cb.total_tokens)
        print("Cost:", cb.total_cost)
This gives you token + cost info without extra work.