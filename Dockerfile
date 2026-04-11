# Use a lightweight Node.js base image
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package files first to leverage Docker caching
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy the rest of your application code
COPY . .

# Expose the port your Express app runs on internally
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]