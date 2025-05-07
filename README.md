# Text to SQL over Mondial using LangChain 

This project explores **text-to-SQL generation** using the [LangChain](https://python.langchain.com/docs/introduction/) framework, GPT models (via OpenAI), and the **Mondial database** running inside an **Oracle Docker container**.  

It is part of an ongoing research project led by [Mrunal (Moon) Mustapure](https://moons-portfolio.netlify.app), funded by the **Undergraduate Research Award** at the **University of British Columbia**<img src="https://ires.ubc.ca/files/2020/01/ubc-logo.png" width="20" height="20" style="vertical-align: middle;" />, and supervised by [Dr. Ramon Lawrence](https://cmps-people.ok.ubc.ca/rlawrenc/).

The broader goal is to evaluate how well large language models understand database schemas, reason over structured data, and generate accurate SQL queries. This research will involve systematic **evaluation**, **optimization**, and **application** of text-to-SQL methods followed by LLMs.

---
## 📁 Project Structure

- datasets/ – Contains the Mondial schema and data SQL files (mondial-schema.sql, mondial-inputs.sql).
- experiments/ – Contains different experiment pipelines (e.g., table recall, column recall, SQL generation using GPT).
- functions/ – Utility functions for database connection and schema interaction with LangChain.

---
## 🚀 Getting Started

### 1. Install Dependencies

pip install -r requirements.txt


### 2. Start Oracle Database via Docker
docker start oracle-xe

### 3. Load the Mondial Dataset

docker exec -it oracle-xe bash
sqlplus MONDIAL/oraclee@//localhost:1521/XE
@/mondial-schema.sql
@/mondial-inputs.sql


### 4. Add .env file at the root

Create .env file and add OPEN API Key
OPENAI_API_KEY = your_key


### 5. Run the Jupyter NOtebook Scripts under experiments

---

## 🧪 Current Goal

Evaluate table and column recall performance

Gradually update deprecated LangChain components (LLMChain → Runnable, etc.)

Minimize API cost by running one query at a time

---

## 📌 Notes

Model used: gpt-3.5-turbo

Database: Oracle XE 21c (Docker)

LangChain version: 0.3.6

---

## Credits:

- Tahsin Jawwad: Research and repository - [Text2SQL](https://github.com/tahsinj/Text2SQL)
- Nascimento et al. (2024) original research and repository: [text_to_sql_chatgpt_real_world](https://github.com/dudursn/text_to_sql_chatgpt_real_world)
- [XiYan-SQL](https://github.com/XGenerationLab/XiYan-SQL)
- [M-Schema](https://github.com/XGenerationLab/M-Schema)

---