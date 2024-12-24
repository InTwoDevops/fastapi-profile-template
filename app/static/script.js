document.getElementById('api-form').addEventListener('submit', async function(event) {
    event.preventDefault();

    const endpoint = document.getElementById('endpoint').value;
    const limit = document.getElementById('limit').value;
    let url = `/${endpoint}`;

    if (endpoint === 'high-cpu-usage') {
        url += `?limit=${limit}`;
    }

    try {
        const response = await fetch(url);
        const data = await response.json();
        document.getElementById('result').innerText = JSON.stringify(data, null, 2);
    } catch (error) {
        document.getElementById('result').innerText = 'Error fetching data';
    }
});
