package fu.ce190435.productservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    private String id;
    private String name;
    private String imageUrl;
    private String description;
    private Integer itemCount;
}

