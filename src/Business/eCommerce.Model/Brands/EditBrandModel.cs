﻿using Microsoft.AspNetCore.Http;

namespace eCommerce.Model.Brands;

public class EditBrandModel
{
    public string Name { get; set; }
    public string Description { get; set; }
    public IFormFile? LogoUpload { get; set; }
    public bool? Status { get; set; }
}