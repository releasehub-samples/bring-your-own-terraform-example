exports.handler = async (event) => {
    console.log(`Event received by Lambda: ${JSON.stringify(event, null, 2)}`)
    return {
        code: 200,
        data: `Hello from AWS Lambda!`
    };
};