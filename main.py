from fastapi import

FastAPIapp = FastAPI()

@app.get('/hello')
def hello():
    """Test endpoint"""

    return {'hello': 'world'}
