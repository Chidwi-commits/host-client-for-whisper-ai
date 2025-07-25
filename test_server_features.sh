#!/bin/bash

# Test script for Whisper Server new features
# Testing script for new Whisper server features

SERVER_URL="http://localhost:5000"

echo "=== Testing Whisper Server New Features ==="
echo "Server URL: $SERVER_URL"
echo ""

# Function to make HTTP requests with error handling
make_request() {
    local method=$1
    local endpoint=$2
    local description=$3
    
    echo "🔍 Testing: $description"
    echo "   Request: $method $SERVER_URL$endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$SERVER_URL$endpoint" 2>/dev/null)
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$SERVER_URL$endpoint" 2>/dev/null)
    fi
    
    if [ $? -eq 0 ]; then
        http_code=$(echo "$response" | tail -n1 | cut -d: -f2)
        body=$(echo "$response" | head -n -1)
        
        echo "   Status: $http_code"
        echo "   Response:"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        echo ""
    else
        echo "   ❌ Connection failed - server might not be running"
        echo ""
    fi
}

# Test 1: Health Check
make_request "GET" "/health" "Health Check Endpoint"

# Test 2: Server Status
make_request "GET" "/status" "Server Status Monitoring"

# Test 3: Reset Server
echo "⚠️  Testing Reset Functionality"
echo "   This will reset the server state..."
read -p "   Continue? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make_request "POST" "/reset" "Server Reset"
else
    echo "   Skipped reset test"
    echo ""
fi

# Test 4: Status after reset
echo "🔄 Checking status after reset:"
make_request "GET" "/status" "Status After Reset"

# Test 5: Check if transcribe endpoint is accessible
echo "📝 Testing transcribe endpoint availability (without file):"
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$SERVER_URL/transcribe" 2>/dev/null)
if [ $? -eq 0 ]; then
    http_code=$(echo "$response" | tail -n1 | cut -d: -f2)
    body=$(echo "$response" | head -n -1)
    
    echo "   Status: $http_code (expected 400 - No file provided)"
    echo "   Response:"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    echo ""
else
    echo "   ❌ Connection failed"
    echo ""
fi

echo "=== Test Summary ==="
echo "✅ All endpoint tests completed"
echo ""
echo "📚 For detailed API usage examples:"
echo "   cat api_examples.md"
echo ""
echo "🚀 To start transcription with a real file:"
echo "   curl -X POST -F \"file=@test.wav\" $SERVER_URL/transcribe --output transcript.txt"
echo ""
echo "🔍 To monitor server in real-time:"
echo "   watch -n 2 'curl -s $SERVER_URL/status | jq'" 