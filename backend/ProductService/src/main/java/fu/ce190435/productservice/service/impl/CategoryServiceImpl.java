package fu.ce190435.productservice.service.impl;

import fu.ce190435.productservice.common.ApiException;
import fu.ce190435.productservice.dto.CategoryDTO;
import fu.ce190435.productservice.entity.Category;
import fu.ce190435.productservice.repository.CategoryRepository;
import fu.ce190435.productservice.repository.ProductRepository;
import fu.ce190435.productservice.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryDTO> getAllCategories() {
        return categoryRepository.findAll()
                .stream()
                .map(this::toCategoryDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public CategoryDTO getCategoryById(String id) {
        if (id == null || id.isBlank()) {
            throw ApiException.badRequest("Mã danh mục không được để trống");
        }

        Category category = categoryRepository.findById(id.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy danh mục với mã: " + id));

        return toCategoryDTO(category);
    }

    private CategoryDTO toCategoryDTO(Category category) {
        int productCount = productRepository.findByCategory_Id(category.getId()).size();
        int finalCount = productCount > 0
                ? productCount
                : (category.getItemCount() != null ? category.getItemCount() : 0);

        return CategoryDTO.builder()
                .id(category.getId())
                .name(category.getName())
                .imageUrl(category.getImageUrl())
                .description(category.getDescription())
                .itemCount(finalCount)
                .build();
    }
}

