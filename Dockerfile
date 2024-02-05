# Use the official Nginx base image
FROM nginx:latest

# Set the working directory to the default Nginx public directory
WORKDIR /usr/share/nginx/html

# Copy your static content (HTML, CSS, JS, etc.) to the container
#COPY ./your-static-content /usr/share/nginx/html

# Expose port 3000
EXPOSE 80

# Command to start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]