package fu.ce190435.productservice.service;

import fu.ce190435.productservice.dto.CategoryDTO;

import java.util.List;

public interface CategoryService {
    List<CategoryDTO> getAllCategories();

    CategoryDTO getCategoryById(String id);
}

