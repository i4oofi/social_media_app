import PIL.Image

# Open the original image
img = PIL.Image.open("assets/images/logo.png")

# Calculate new size (600x600)
new_size = (600, 600)
new_img = PIL.Image.new("RGBA", new_size, (255, 255, 255, 0))

# Calculate position to center the original image
x = (new_size[0] - img.size[0]) // 2
y = (new_size[1] - img.size[1]) // 2

# Paste the original image
new_img.paste(img, (x, y))

# Save the new image
new_img.save("assets/images/logo_padded.png")
